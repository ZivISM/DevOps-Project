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
# ACM Certificate-ARN
###############################################################################
# Output the certificate ARN for use in other resources
output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
} 