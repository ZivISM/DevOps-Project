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


# Global settings that apply to all ArgoCD components
global:
  nodeSelector:
    workload-type: system-critical

  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

# Component-specific configurations

controller:
  nodeSelector:
    workload-type: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

repoServer:
  nodeSelector:
    workload-type: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

applicationSet:
  nodeSelector:
    workload-type: system-critical
  tolerations:
    - key: "CriticalWorkload"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

redis:
  nodeSelector:
    workload-type: system-critical
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
    helm_release.karpenter,
    module.karpenter,
    helm_release.karpenter,
    helm_release.karpenter-manifests,
    helm_release.nginx,
  ]
}
