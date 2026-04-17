variable "alb_security_group_id" {
  description = "The security group ID to associate with the ALB."
  type        = string
}

variable "public_subnet_az1_id" {
  description = "The ID of the public subnet in availability zone 1."
  type        = string
}

variable "public_subnet_az2_id" {
  description = "The ID of the public subnet in availability zone 2."
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be created."
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the ACM certificate to use for the HTTPS listener."
  type        = string
}
