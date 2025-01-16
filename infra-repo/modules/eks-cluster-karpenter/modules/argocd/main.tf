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
    module.karpenter,
    helm_release.karpenter-manifests,
    helm_release.nginx,
  ]
}

###############################################################################
# ArgoCD Helm
###############################################################################

resource "kubectl_manifest" "habits" {
  yaml_body = <<YAML
# gitops-repo/base/applications/dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: habitspace-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${var.github_repo}
    targetRevision: development
    path: app-repo/
    helm:
      valueFiles:
        - ../environments/development/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: habitspace-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

---
# gitops-repo/base/applications/staging.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: habitspace-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${var.github_repo}
    targetRevision: main
    path: app-repo/
    helm:
      valueFiles:
        - ../environments/staging/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: habitspace-staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: false  # Require manual approval for staging
    syncOptions:
      - CreateNamespace=true

---
# gitops-repo/base/applications/prod.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: habitspace-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${var.github_repo}
    targetRevision: main
    path: app-repo/
    helm:
      valueFiles:
        - ../environments/production/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: habitspace-prod
  syncPolicy:
    automated:
      prune: false  # Disable automatic pruning for production
      selfHeal: false  # Require manual approval for production
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true  # Only apply changes that are out of sync
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas  # Ignore replica count differences in prod
YAML
}
