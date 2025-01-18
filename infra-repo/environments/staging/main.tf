module "network" {
  source    = "../../modules/network"
  vpc_cidr  = var.vpc_cidr
  environment = var.environment
  project = var.project
  tags = var.tags
  aws_region = var.aws_region
  num_zones = var.num_zones
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  karpenter_tag = var.karpenter_tag
}

module "eks-cluster-karpenter" {
  source = "../../modules/eks-cluster-karpenter"
  environment = var.environment
  enable_karpenter = var.enable_karpenter
  fargate_additional_profiles = var.fargate_additional_profiles
  github_repo = var.github_repo
  project = var.project
  tags = var.tags
  aws_region = var.aws_region
  vpc_cidr = var.vpc_cidr
  num_zones = var.num_zones
  eks_enabled = var.eks_enabled
  k8s_version = var.k8s_version
  cluster_addons = var.cluster_addons
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver
  karpenter_tag = var.karpenter_tag
  eks_managed_node_groups = var.eks_managed_node_groups
  map_users = var.map_users
  map_accounts = var.map_accounts
  nginx_controller_service_type = var.nginx_controller_service_type
  certmanager_enabled = var.certmanager_enabled
}

