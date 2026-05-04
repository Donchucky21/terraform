variable "name_prefix" {
  type    = string
  default = "my-nodejs-webapp"
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "app_security_group_id" {
  type = string
}

variable "user_data" {
  type = string
}

variable "iam_instance_profile_name" {
  type    = string
  default = null
}

