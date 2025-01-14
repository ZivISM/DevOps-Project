###############################################################################
# Route53 Zone
###############################################################################
resource "aws_route53_zone" "main" {
  name = var.domain_name

  force_destroy = true
}

###############################################################################
# Route53 Records
###############################################################################
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [kubernetes_ingress_v1.alb_nginx.status.0.load_balancer.0.ingress.0.hostname]

  depends_on = [ kubernetes_ingress_v1.alb_nginx ]
}

resource "aws_route53_record" "argocd" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "argocd.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [kubernetes_ingress_v1.alb_nginx.status.0.load_balancer.0.ingress.0.hostname]

  depends_on = [ kubernetes_ingress_v1.alb_nginx ]
}

resource "aws_route53_record" "prometheus" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "prometheus.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [kubernetes_ingress_v1.alb_nginx.status.0.load_balancer.0.ingress.0.hostname]

  depends_on = [ kubernetes_ingress_v1.alb_nginx ]
}


# data "aws_lb" "ingress" {
#   tags = {
#     "ingress.k8s.aws/stack"     = "ingress-nginx/alb-nginx"
#   }

#   depends_on = [
#     helm_release.aws_lbc,
#     kubernetes_ingress_v1.alb_nginx
#   ]
# }
