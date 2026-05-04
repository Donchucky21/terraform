output "alb_dns_name" {
  value = module.alb.alb_load_balancer_dns_name
}

output "target_group_arn" {
  value = module.alb.alb_target_group_arn
}

output "asg_name" {
  value = module.asg.asg_name
}

output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "launch_template_id" {
  value = module.launch_template.launch_template_id
}