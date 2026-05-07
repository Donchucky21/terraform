# 🚀 Student Registration Portal on AWS (Terraform + CI/CD)

## 📌 Overview

This project demonstrates a production-style deployment of a full-stack **Student Registration Portal** on AWS using **Terraform (IaC)** and **GitHub Actions (CI/CD)**.

The system is designed to be **scalable, secure, and automated**, following real-world DevOps practices.

🔗 Live Application:
https://portal.starttechapp.uk

---

## 🏗️ Architecture

```text
User
  ↓
Route 53 (DNS)
  ↓
ACM (SSL Certificate)
  ↓
Application Load Balancer (HTTPS)
  ↓
Auto Scaling Group (EC2 instances)
  ↓
Node.js / Next.js App (Port 8080)
  ↓
RDS PostgreSQL Database

Supporting Services:
- S3 → App artifact storage
- IAM → Secure access control
- CloudWatch → Logging
- Bastion Host → Secure SSH access

Tech Stack
Terraform (Infrastructure as Code)
AWS (VPC, EC2, ALB, ASG, RDS, S3, IAM, Route53, ACM)
Node.js / Next.js
Prisma ORM
PostgreSQL (RDS)
GitHub Actions (CI/CD)
📦 Infrastructure Components

✔ Custom VPC (public & private subnets)
✔ NAT Gateway + Internet Gateway
✔ Application Load Balancer (HTTPS)
✔ Auto Scaling Group (self-healing EC2)
✔ Launch Template (bootstrap automation)
✔ RDS PostgreSQL (private subnet)
✔ Bastion Host (secure access)
✔ Route 53 (DNS)
✔ ACM (SSL certificate)
✔ IAM roles & policies
✔ CloudWatch logging

🔄 CI/CD Workflow

GitHub Actions pipeline:

On Pull Request
terraform fmt
terraform validate
terraform plan
Manual Trigger (Apply)
terraform apply


🧪 Validation

Check app health:

curl https://portal.starttechapp.uk/api/health

Expected output:

{"status":"ok","database":"connected"}


🔐 Security Features
Private subnets for app & database
Bastion host for controlled access
IAM roles for EC2 (no hardcoded credentials)
HTTPS enforced via ALB + ACM
Security groups with least privilege

💰 Cost Control
AWS Budget alerts configured
Auto Scaling prevents over-provisioning
Terraform destroy available for cleanup

🧹 Cleanup
terraform destroy

🎯 Key Achievements
Fully automated infrastructure deployment
CI/CD integration with GitHub Actions
High availability using Auto Scaling
Secure architecture with private networking
Production-ready HTTPS setup
📸 Screenshots (Add yours)
ALB healthy targets
Terraform apply success
GitHub Actions runs
Live application
CloudWatch logs
Route53 + ACM


👤 Author

Chukwuka Agupugo
Cloud / DevOps Engineer