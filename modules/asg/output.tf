output "asg_name" {
  value = aws_autoscaling_group.app_asg.name
}

output "asg_arn" {
  value = aws_autoscaling_group.app_asg.arn
}