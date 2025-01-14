###############################################################################
# IAM
###############################################################################

module "allow_eks_acceess_iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.48.0"
  name  = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "eks:DescribeCluster",
        ]
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

###############################################################################
# EKS Admin IAM Role
###############################################################################
module "eks_admins_iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.48.0"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_acceess_iam_policy.arn]
  
  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}

###############################################################################
# EKS User IAM User
###############################################################################
# module "eks_iam_user" {
#     source = "terraform-aws-modules/iam/aws//modules/iam-user"
#     version = "5.48.0"

#     name                          = "eks-user"
#     create_iam_access_key         = false
#     create_iam_user_login_profile = false    

#     force_destroy = true
# }


###############################################################################
# EKS Admins IAM Group
###############################################################################
module "allow_assume_eks_admins_iam_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.48.0"
  name  = "allow-assume-eks-admin-iam-role"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "sts:AssumeRole",
        ]
        Effect = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn
      },
    ]
  })
}

###############################################################################
# EKS Admins IAM Group
###############################################################################
module "eks_admins_iam_group" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.48.0"
  
  name                              = "eks-admins"
  attach_iam_self_management_policy = false
  create_group                      = true
  # group_users                       = [module.eks_iam_user.iam_user_name]
  custom_group_policy_arns          = [module.allow_assume_eks_admins_iam_policy.arn]
}

###############################################################################
# EKS Admins IAM Group Membership
###############################################################################
resource "aws_iam_user_group_membership" "localadmin_to_eks_admins" {
  user = "localadmin"
  groups = [
    module.eks_admins_iam_group.group_name
  ]
}