###############################################################################
# ArgoCD URL
###############################################################################
output "argocd_url" {
  value = "https://argocd.${var.domain_name}"
  description = "URL to access ArgoCD UI"
}