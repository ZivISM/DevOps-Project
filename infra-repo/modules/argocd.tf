resource "kubectl_manifest" "argocd_network_policy" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: argocd-redis-network-policy
  namespace: argocd
spec:
  egress:
    - ports:
        - port: 53
          protocol: UDP
        - port: 53
          protocol: TCP
        - port: 16443
          protocol: TCP
  YAML
}

###############################################################################
# ArgoCD Helm
###############################################################################
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.1.3" 
  create_namespace = true

  set {
    name = "config.params.server\\.insecure"
    value = "true"
  }

  values = [
    <<EOF
config:
  params:
    server.insecure: true
server:
  service:
    type: ClusterIP
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - argocd.${var.domain_name}
    https: false


global:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  domain: argocd.${var.domain_name}

  tolerations:
    - key: "system-critical"
      operator: "Exists"


controller:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

repoServer:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

applicationSet:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

redis:

  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Exists"
      value: "true"
      effect: "NoSchedule"


# Resource requests and limits for better scheduling


# Server

server:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

# Controller 

controller:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

# RepoServer

repoServer:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

# ApplicationSet

applicationSet:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

# Redis

redis:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
EOF
  ]

  depends_on = [
    module.eks,
    module.karpenter,
    helm_release.karpenter-manifests,
    helm_release.nginx,
    resource.kubectl_manifest.argocd_network_policy
  ]
}

###############################################################################
# ArgoCD Application
###############################################################################

# resource "kubectl_manifest" "habits" {
#   yaml_body = <<YAML
# # gitops-repo/base/applications/dev.yaml
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: ${var.project}-${var.environment}
#   namespace: argocd
# spec:
#   project: ${var.project}
#   source:
#     repoURL: ${var.github_repo}
#     targetRevision: ${var.environment}
#     path: app-repo/
#     helm:
#       valueFiles:
#         - ../environments/${var.environment}/values.yaml
#   destination:
#     server: https://kubernetes.default.svc
#     namespace: habitspace-${var.environment}
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
#     syncOptions:
#       - CreateNamespace=true
# YAML

# depends_on = [ helm_release.argocd ]
# }

resource "kubectl_manifest" "argocd_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.zivoosh.online
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443

YAML

  depends_on = [
    helm_release.argocd,
    helm_release.nginx
  ]
}
