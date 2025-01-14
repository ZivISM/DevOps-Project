###############################################################################
# EKS Module
###############################################################################
module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  create                                   = var.eks_enabled
  version                                  = "20.8.4"
  # cluster_name                             = "${var.project}-${var.environment}-cluster"
  cluster_name                             = "myapp-cluster"
  cluster_version                          = var.k8s_version
  cluster_endpoint_private_access          = true
  cluster_endpoint_public_access           = true
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = slice(module.vpc.private_subnets, 0, var.num_zones)
  enable_irsa                              = true
  eks_managed_node_groups                  = var.enable_karpenter ? {} : var.eks_managed_node_groups
  enable_cluster_creator_admin_permissions = true
  tags                                     = var.tags
  node_security_group_tags = {
    "${var.karpenter_tag.key}" = "${var.karpenter_tag.value}"
  }

  fargate_profiles = local.fargate_profile


  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    drachtio_all = {
      description                   = "Node to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 53
      to_port                       = 53
      type                          = "ingress"
      source_cluster_security_group = true
    }

    pod-access = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    cluster_nodes_incoming = {
      description                   = "allow from cluster To node 1025-65535"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  cluster_security_group_additional_rules = {
    ingress_vpn = {
      description = "Acces cluster via vpc"
      protocol    = "TCP"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["${var.vpc_cidr}"]
    }
  }

  cloudwatch_log_group_retention_in_days = "7"
  cluster_enabled_log_types              = local.enabled_cluster_logs
  depends_on                             = [module.vpc, 
                                          #  null_resource.prep_vpn
                                          ]

  }



###############################################################################
# EKS Auth
###############################################################################

module "eks-auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.8.4"

  manage_aws_auth_configmap = true

  aws_auth_roles = local.merged_map_roles
  aws_auth_users = var.map_users

  aws_auth_accounts = var.map_accounts
  depends_on        = [module.eks]
}

###############################################################################
# EBS CSI Driver
###############################################################################
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "AmazonEKS_EBS_CSI_Driver_Role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = {
    Name = "EBS CSI Driver Role"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}