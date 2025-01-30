###############################################################################
# Route53 Nameservers
###############################################################################
output "route53_nameservers" {
  description = "Nameservers for the Route53 zone - update these in GoDaddy"
  value = {
    domain = var.domain_name
    nameservers = aws_route53_zone.main.name_servers
    instructions = "Please update these nameservers in your GoDaddy domain settings:"
  }
}

###############################################################################
# GoDaddy Instructions
###############################################################################
output "godaddy_instructions" {
  description = "Step-by-step instructions for GoDaddy configuration"
  value = <<-EOT
    1. Log into GoDaddy
    2. Go to Domain Settings for ${var.domain_name}
    3. Find "Nameservers" section
    4. Click "Change" or "Edit"
    5. Select "Custom" or "Enter custom nameservers"
    6. Remove existing nameservers
    7. Add all 4 AWS nameservers listed above
    8. Save changes
    
    Note: DNS propagation can take up to 48 hours (usually much faster)
  EOT
}


###############################################################################
# Cluster Information
###############################################################################
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

###############################################################################
# Kubectl Configuration
###############################################################################
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}

###############################################################################
# ArgoCD URL
###############################################################################
output "argocd_url" {
  value = "https://argocd.${var.domain_name}"
  description = "URL to access ArgoCD UI"
}

###############################################################################
# HPA
###############################################################################
output "hpa_status" {
  value = kubernetes_horizontal_pod_autoscaler_v1.system_critical_hpa
  description = "Status of the system-critical HPA"
}


