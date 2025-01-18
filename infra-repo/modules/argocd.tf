###############################################################################
# ArgoCD Helm
###############################################################################
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.7.11" 
  create_namespace = true

  set {
    name = "config.params.server\\.insecure"
    value = "true"
  }

  values = [
    <<EOF

server:
  service:
    type: ClusterIP
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - argocd.${var.domain_name}
    annotations:
      kubernetes.io/ingress.class: nginx


global:
  nodeSelector:
    karpenter.sh/nodepool: system-critical

  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"


controller:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

repoServer:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

applicationSet:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

redis:
  nodeSelector:
    karpenter.sh/nodepool: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
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