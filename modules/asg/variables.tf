variable "name" {
  type    = string
  default = "my-nodejs-app-asg"
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "health_check_grace_period" {
  type    = number
  default = 300
}

variable "launch_template_id" {
  type = string
}