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
# Wildcard record for all subdomains
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${var.domain_name}"  # This will match any subdomain
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
    "prometheus.${var.domain_name}",
  ]

  wait_for_validation = false

  tags = {
    Name        = var.domain_name
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [aws_route53_zone.main, helm_release.nginx]
}



data "aws_acm_certificate" "cert" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
  
  depends_on = [module.acm]
}

###############################################################################
# Kubernetes Ingress
###############################################################################

resource "kubernetes_ingress_v1" "alb_nginx" {
  wait_for_load_balancer = true
  metadata {
    name      = "alb-nginx"
    namespace = "ingress-nginx"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"        = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path"   = "/healthz"
      "alb.ingress.kubernetes.io/certificate-arn"    = "${data.aws_acm_certificate.cert.arn}"
      "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
      "alb.ingress.kubernetes.io/load-balancer-name" = "${var.project}-alb"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "nginx-ingress-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    #helm_release.aws_lbc,
    helm_release.nginx,
    module.eks,
    module.vpc,
    #aws_eks_pod_identity_association.aws_lbc,
    module.acm,
    helm_release.karpenter-manifests
  ]
}


###############################################################################
# Nginx Ingress Controller Helm
###############################################################################
resource "helm_release" "nginx" {
  name             = "nginx-ingress-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  # values           = [file("${path.module}/values/ingress-nginx.yaml")]
  values = [<<EOF
    service:
      type: ${var.nginx_controller_service_type}
    ingressClassResource:
      name: nginx
      enabled: true

  EOF
  ]
  
  depends_on = [
    #helm_release.aws_lbc,
    module.eks, 
    module.karpenter,
    helm_release.karpenter,
    helm_release.karpenter-manifests,
  ]
}
