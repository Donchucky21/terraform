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