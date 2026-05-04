output "launch_template_id" {
  value = aws_launch_template.app_lt.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.app_lt.latest_version
}

output "launch_template_name" {
  value = aws_launch_template.app_lt.name
}