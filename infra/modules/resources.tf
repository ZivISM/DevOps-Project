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
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"  # Changed to A record for alias

  alias {
    name                   = data.aws_alb.alb.dns_name
    zone_id               = data.aws_alb.alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [kubernetes_ingress_v1.alb_nginx]
}

data "aws_alb" "alb" {
name = "${var.environment}-alb"
depends_on = [time_sleep.alb_delete_delay]
}

resource "time_sleep" "alb_loading_delay" {
  depends_on = [
    kubernetes_ingress_v1.alb_nginx,
  ]

  destroy_duration = "60s"   
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
  ]

  wait_for_validation = false

  tags = {
    Name        = var.domain_name
    Environment = var.environment
    Terraform   = "true"
  }

  depends_on = [aws_route53_zone.main, helm_release.nginx]
}

###############################################################################
# Kubernetes Ingress
###############################################################################
resource "kubernetes_ingress_v1" "alb_nginx" {
  wait_for_load_balancer = false
  
  metadata {
    name      = "alb-nginx"
    namespace = "ingress-nginx"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"        = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path"   = "/healthz"
      "alb.ingress.kubernetes.io/certificate-arn"    = "${module.acm.acm_certificate_arn}"
      "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
      "alb.ingress.kubernetes.io/load-balancer-name" = "${var.environment}-alb"
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
              name = helm_release.nginx.name
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
    time_sleep.alb_delete_delay
  ]
}

resource "time_sleep" "alb_delete_delay" {
  depends_on = [
    helm_release.nginx,
  ]

  destroy_duration = "25s"   
}

###############################################################################
# Nginx Ingress Controller Helm
###############################################################################
resource "helm_release" "nginx" {
  name             = "${var.project}"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  values = [<<EOF
  controller: 
    service:
      type: ClusterIP
    ingressClass:
      name: nginx
      enabled: true
    nodeSelector:
      nodepool: system-critical
    tolerations:
      - key: system-critical
        operator: "Equal"
        effect: NoSchedule
  EOF
  ]
  
  depends_on = [
    module.eks_blueprints_addons,
  ]
}

###############################################################################
# System-Critical HPA
###############################################################################
resource "kubernetes_horizontal_pod_autoscaler_v1" "system_critical_hpa" {
  for_each = {
    "coredns" = {
      namespace = "kube-system"
      min_replicas = 1
      max_replicas = 2
      target_cpu_utilization = 80
    }
    "${helm_release.nginx.name}" = {
      namespace = "ingress-nginx" 
      min_replicas = 1
      max_replicas = 2
      target_cpu_utilization = 75
    }
    "kube-prometheus-stack" = {
      namespace = "kube-prometheus-stack"
      min_replicas = 1
      max_replicas = 2
      target_cpu_utilization = 75
    }
  }

  metadata {
    name = each.key
    namespace = each.value.namespace
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = each.key
    }

    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas

    target_cpu_utilization_percentage = each.value.target_cpu_utilization
  }

  depends_on = [
    module.eks_blueprints_addons,
    helm_release.nginx
  ]
}
