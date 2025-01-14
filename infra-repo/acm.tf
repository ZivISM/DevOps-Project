###############################################################################
# ACM
###############################################################################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id    = aws_route53_zone.main.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}",
    "argocd.${var.domain_name}",
    "app.${var.domain_name}"
  ]

  wait_for_validation = true

  tags = {
    Name        = var.domain_name
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [aws_route53_zone.main]
}

# Output the certificate ARN for use in other resources
output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
} 

data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
  
  depends_on = [module.acm]
}