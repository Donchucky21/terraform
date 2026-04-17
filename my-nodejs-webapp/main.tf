 #configure aws provider
provider "aws" {
  region = "eu-west-2"
  profile = "default"
  }

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
}

module "acm" {
  source           = "../modules/acm"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name
}

module "alb" {
  source                 = "../modules/alb"
  alb_security_group_id  = module.security_groups.alb_security_group_id
  vpc_id                 = module.vpc.vpc_id
  public_subnet_az1_id   = module.vpc.public_subnet_az1_id
  public_subnet_az2_id   = module.vpc.public_subnet_az2_id
  certificate_arn        = module.acm.certificate_arn
}


