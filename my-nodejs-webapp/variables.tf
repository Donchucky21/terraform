variable "project_name" {
  description = "Project name variable"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr block variable"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "public subnet AZ1 CIDR Block"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "public subnet AZ2 CIDR Block"
  type        = string
}

variable "private_app_subnet_az1_cidr" {
  description = "Private App subnet az1 CIDR Block"
  type        = string
}

variable "private_app_subnet_az2_cidr" {
  description = "Private App subnet az2 CIDR Block"
  type        = string
}

variable "private_db_subnet_az1_cidr" {
  description = "Private DB subnet az1 CIDR Block"
  type        = string
}

variable "private_db_subnet_az2_cidr" {
  description = "Private DB subnet az2 CIDR Block"
  type        = string
}

variable "domain_name" {}
variable "alternative_name" {}
variable "hosted_zone_name" {
  type = string
}

variable "my_ip" {
  description = "Your public IP address for SSH access to bastion"
  type        = string
}


variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = null
}

variable "iam_instance_profile_name" {
  type    = string
  default = null
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "health_check_path" {
  type    = string
  default = "/api/health"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "app_min_size" {
  type    = number
  default = 1
}

variable "app_max_size" {
  type    = number
  default = 3
}

variable "app_desired_capacity" {
  type    = number
  default = 1
}

variable "s3_bucket" {
  type = string
}

variable "s3_key" {
  type = string
}

