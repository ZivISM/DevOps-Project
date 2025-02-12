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
  cm:
    create: true
  params:
    create: true
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
    nodepool: system-critical
  domain: argocd.${var.domain_name}

  tolerations:
    - key: "system-critical"
      operator: "Exists"


controller:
  nodeSelector:
    nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

repoServer:
  nodeSelector:
    nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

applicationSet:
  nodeSelector:
    nodepool: system-critical
  tolerations:
    - key: "system-critical"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

redis:

  nodeSelector:
    nodepool: system-critical
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
    helm_release.nginx,
  ]
}

resource "kubectl_manifest" "argocd_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.${var.domain_name}
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
  ]
}
