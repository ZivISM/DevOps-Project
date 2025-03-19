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

  set {
    name = "server.extraArgs[0]"
    value = "--insecure"
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
    enabled: false
    ingressClassName: nginx
    hosts:  
      - argocd.${var.domain_name}
    https: false

global:
  nodeSelector:
    nodepool: system
  domain: argocd.${var.domain_name}

  tolerations:
    - key: "system"
      operator: "Exists"


controller:
  nodeSelector:
    nodepool: system
  tolerations:
    - key: "system"
      operator: "Equal"
      effect: "NoSchedule"
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

repoServer:
  nodeSelector:
    nodepool: system
  tolerations:
    - key: "system"
      operator: "Equal"
      effect: "NoSchedule"
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 500m
      memory: 512Mi

applicationSet:
  nodeSelector:
    nodepool: system
  tolerations:
    - key: "system"
      operator: "Equal"
      effect: "NoSchedule"
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

redis:
  nodeSelector:
    nodepool: system
  tolerations:
    - key: "system"
      operator: "Exists"
      effect: "NoSchedule"
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
  name: argo-ingress-manifested
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
              number: 80

YAML

  depends_on = [
    helm_release.argocd,
  ]
}
