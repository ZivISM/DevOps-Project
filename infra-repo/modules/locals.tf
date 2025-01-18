locals {
  enabled_cluster_logs = ["api", "audit", "controllerManager", "scheduler", "authenticator"]
  fargate_profile = var.enable_karpenter ? merge({
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    },
  var.fargate_additional_profiles) : tomap(var.fargate_additional_profiles)
  
  merged_map_roles = distinct(concat(
    var.enable_karpenter ? [
      {
        rolearn  = module.karpenter[0].iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      {
        rolearn  = module.karpenter[0].node_iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      {
        rolearn  = data.aws_caller_identity.current.arn
        username = "clusteradmin"
        groups   = ["system:masters"]
      }
      ] : [
      {
        rolearn  = data.aws_caller_identity.current.arn
        username = "clusteradmin"
        groups   = ["system:masters"]
      }
    ],

    var.map_roles,
  ))

}

data "aws_caller_identity" "current" {}



locals {
  eks_cluster_endpoint = try(module.eks.cluster_endpoint, "")
  eks_cluster_ca_cert  = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  eks_cluster_name     = try(module.eks.cluster_name, "")
}