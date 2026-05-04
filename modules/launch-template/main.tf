resource "aws_launch_template" "app_lt" {
  name_prefix            = var.name_prefix
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  update_default_version = true

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(var.user_data)

  monitoring {
    enabled = true
  }

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name == null ? [] : [1]
    content {
      name = var.iam_instance_profile_name
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "my-nodejs-app"
    }
  }
}