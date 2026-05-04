#  #configure aws provider
# provider "aws" {
#   region = "eu-west-2"
#   profile = "default"
#   }

# Create VPC
module "vpc" {
  source                      = "../modules/vpc"
  project_name                = var.project_name
  vpc_cidr                    = var.vpc_cidr
  public_subnet_az1_cidr      = var.public_subnet_az1_cidr
  public_subnet_az2_cidr      = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr = var.private_app_subnet_az2_cidr
  private_db_subnet_az1_cidr  = var.private_db_subnet_az1_cidr
  private_db_subnet_az2_cidr  = var.private_db_subnet_az2_cidr
}

module "security_groups" {
  source   = "../modules/security-groups"
  vpc_id   = module.vpc.vpc_id
  app_port = var.app_port
  db_port  = var.db_port
  my_ip    = var.my_ip
}

module "acm" {
  source           = "../modules/acm"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name
  hosted_zone_name = var.hosted_zone_name
}

module "alb" {
  source                = "../modules/alb"
  alb_security_group_id = module.security_groups.alb_security_group_id
  vpc_id                = module.vpc.vpc_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  certificate_arn       = module.acm.certificate_arn
  app_port              = var.app_port
  health_check_path     = var.health_check_path
}


module "rds" {
  source = "../modules/rds"

  identifier              = "my-nodejs-db"
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_port                 = var.db_port
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  private_data_subnet_ids = [module.vpc.private_db_subnet_az1_id, module.vpc.private_db_subnet_az2_id]
  db_security_group_id    = module.security_groups.db_security_group_id
  backup_retention_period = 7
  multi_az                = false
  deletion_protection     = false
  skip_final_snapshot     = true
}

locals {
  user_data = templatefile("${path.module}/userdata/bootstrap.sh.tpl", {

    aws_region = var.aws_region
    s3_bucket  = var.s3_bucket
    s3_key     = var.s3_key

    db_host     = module.rds.db_endpoint
    db_port     = module.rds.db_port
    db_name     = var.db_name
    db_user     = var.db_username
    db_password = var.db_password
    app_port    = var.app_port
  })
}

module "launch_template" {
  source = "../modules/launch-template"

  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  app_security_group_id     = module.security_groups.app_security_group_id
  user_data                 = local.user_data
  iam_instance_profile_name = module.iam.instance_profile_name
}

module "asg" {
  source = "../modules/asg"

  launch_template_id = module.launch_template.launch_template_id
  private_subnet_ids = [module.vpc.private_app_subnet_az1_id, module.vpc.private_app_subnet_az2_id]
  target_group_arn   = module.alb.alb_target_group_arn
  min_size           = var.app_min_size
  max_size           = var.app_max_size
  desired_capacity   = var.app_desired_capacity
}

module "iam" {
  source = "../modules/iam"

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key
}

# module "launch_template" {
#   source = "../modules/launch-template"

#   ami_id                    = var.ami_id
#   instance_type             = var.instance_type
#   key_name                  = var.key_name
#   app_security_group_id     = module.security_groups.app_security_group_id
#   user_data                 = local.user_data
#   iam_instance_profile_name = module.iam.instance_profile_name
# }