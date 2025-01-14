# ###############################################################################
# # Cert Manager Helm
# ###############################################################################
# resource "helm_release" "cert_manager" {
#   name             = "cert-manager"
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true
#   version          = "v1.13.0"
  
#   # Add replace flag to force replacement of existing release
#   replace          = true
#   force_update     = true
#   cleanup_on_fail  = true

#   values = [
#     <<-EOT
#     installCRDs: true
#     replicaCount: 1
#     global:
#       leaderElection:
#         namespace: cert-manager
#     EOT
#   ]

  
#   wait          = true
#   wait_for_jobs = true
#   timeout       = 300  # 5 minutes

#   depends_on = [
#     module.eks, 
#     helm_release.karpenter,
#     module.karpenter,

#   ]
# }

# output "cert_manager_status" {
#   value = helm_release.cert_manager.status
# }