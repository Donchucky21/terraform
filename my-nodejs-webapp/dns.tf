data "aws_route53_zone" "main" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_load_balancer_dns_name
    zone_id                = module.alb.alb_load_balancer_zone_id
    evaluate_target_health = true
  }
}

# resource "aws_route53_record" "www_alias" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = module.alb.alb_load_balancer_dns_name
#     zone_id                = module.alb.alb_load_balancer_zone_id
#     evaluate_target_health = true
#   }
# }