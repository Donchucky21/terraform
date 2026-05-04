#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

AWS_REGION="${aws_region}"
S3_BUCKET="${s3_bucket}"
S3_KEY="${s3_key}"

DB_HOST="${db_host}"
DB_PORT="${db_port}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"

APP_BASE="/opt/student-registration-portal"
SRC_ROOT="$APP_BASE/source"
APP_USER="appsvc"
APP_PORT="${app_port}"

echo "========== Starting EC2 bootstrap =========="

apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  unzip \
  postgresql-client \
  build-essential

echo "========== Installing AWS CLI v2 =========="
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -oq awscliv2.zip
./aws/install --update
/usr/local/bin/aws --version

echo "========== Installing CloudWatch Agent =========="
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

echo "========== Installing Node.js 22 =========="
mkdir -p /etc/apt/keyrings
rm -f /etc/apt/keyrings/nodesource.gpg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs

node -v
npm -v

echo "========== Creating app user and directories =========="
id -u "$APP_USER" >/dev/null 2>&1 || useradd --system --create-home --shell /bin/bash "$APP_USER"

mkdir -p "$SRC_ROOT"
rm -rf "$SRC_ROOT"/*
chown -R "$APP_USER:$APP_USER" "$APP_BASE"

echo "========== Downloading application from S3 =========="
mkdir -p "$SRC_ROOT"
cd "$SRC_ROOT"
/usr/local/bin/aws s3 cp "s3://$S3_BUCKET/$S3_KEY" "$SRC_ROOT/student-registration-portal.zip" --region "$AWS_REGION"

echo "========== Validating zip =========="
test -s "$SRC_ROOT/student-registration-portal.zip"

set +e
unzip -tq "$SRC_ROOT/student-registration-portal.zip"
test_rc=$?
set -e

echo "unzip test rc=$test_rc"

if [ "$test_rc" -eq 1 ]; then
  echo "unzip test returned warning status 1; continuing"
elif [ "$test_rc" -ne 0 ]; then
  echo "unzip test failed with exit code $test_rc"
  exit "$test_rc"
fi

echo "========== Unpacking application =========="
set +e
unzip -oq "$SRC_ROOT/student-registration-portal.zip" -d "$SRC_ROOT"
extract_rc=$?
set -e

echo "unzip extract rc=$extract_rc"

if [ "$extract_rc" -eq 1 ]; then
  echo "unzip extraction returned warning status 1; continuing"
elif [ "$extract_rc" -ne 0 ]; then
  echo "unzip extraction failed with exit code $extract_rc"
  ls -lah "$SRC_ROOT"
  exit "$extract_rc"
fi

APP_DIR="$(find "$SRC_ROOT" -mindepth 1 -maxdepth 1 -type d -print -quit)"
echo "APP_DIR=$APP_DIR"

if [ -z "$APP_DIR" ] || [ ! -d "$APP_DIR" ]; then
  echo "ERROR: Could not find extracted app directory under $SRC_ROOT"
  ls -lah "$SRC_ROOT"
  exit 1
fi

chown -R "$APP_USER:$APP_USER" "$APP_BASE"

echo "========== Waiting for PostgreSQL =========="
for i in $(seq 1 30); do
  if PGPASSWORD="$DB_PASSWORD" pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; then
    echo "PostgreSQL is reachable"
    break
  fi
  echo "PostgreSQL not ready yet, retrying in 10 seconds..."
  sleep 10
done

echo "========== Ensuring database exists =========="
if ! PGPASSWORD="$DB_PASSWORD" psql \
  -h "$DB_HOST" \
  -U "$DB_USER" \
  -p "$DB_PORT" \
  -d postgres \
  -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
  PGPASSWORD="$DB_PASSWORD" psql \
    -h "$DB_HOST" \
    -U "$DB_USER" \
    -p "$DB_PORT" \
    -d postgres \
    -c "CREATE DATABASE $DB_NAME;"
else
  echo "Database $DB_NAME already exists"
fi

echo "========== Installing app dependencies and building =========="
export DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?sslmode=require"

runuser -u "$APP_USER" -- env HOME="/home/$APP_USER" DATABASE_URL="$DATABASE_URL" bash <<EOF
set -euo pipefail
cd "$APP_DIR"

npm install
npx prisma generate
npx prisma migrate deploy
npm run build

mkdir -p .next/standalone/.next
cp -r .next/static .next/standalone/.next/static

if [ -d public ]; then
  cp -r public .next/standalone/public
else
  echo "No public directory found, skipping public assets copy"
fi
EOF

echo "========== Creating systemd service =========="
cat >/etc/systemd/system/student-portal.service <<EOF
[Unit]
Description=Student Registration Portal
After=network.target

[Service]
Type=simple
User=$APP_USER
WorkingDirectory=$APP_DIR
Environment=NODE_ENV=production
Environment=PORT=$APP_PORT
Environment=DATABASE_URL=postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME?sslmode=require
ExecStart=/usr/bin/node .next/standalone/server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "========== Starting application service =========="
systemctl daemon-reload
systemctl enable student-portal
systemctl restart student-portal

sleep 5
systemctl status student-portal --no-pager -l || true
journalctl -u student-portal -n 100 --no-pager || true

echo "========== Configuring CloudWatch Agent =========="
cat >/opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/student-portal/user-data",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/student-portal/syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

echo "========== Running local health checks =========="
curl -I "http://127.0.0.1:$APP_PORT" || true
curl -fsS "http://127.0.0.1:$APP_PORT/api/health" || true

echo "========== Bootstrap complete =========="
echo "User-data log: /var/log/user-data.log"
echo "App directory: $APP_DIR"

