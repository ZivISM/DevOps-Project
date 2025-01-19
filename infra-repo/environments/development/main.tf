module "infrastructure" {
  source      = "../../modules"
  
  vpc_cidr  = var.vpc_cidr
  environment = var.environment
  environment_short = var.environment_short
  project = var.project
  tags = var.tags
  aws_region = var.aws_region
  num_zones = var.num_zones
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  domain_name = var.domain_name
  github_repo = var.github_repo
  eks_enabled = var.eks_enabled



  k8s_version = var.k8s_version
  cluster_addons = var.cluster_addons
  enable_karpenter = var.enable_karpenter
  fargate_additional_profiles = var.fargate_additional_profiles

  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_metrics_server = var.enable_metrics_server

  enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver

  karpenter_tag = var.karpenter_tag
  karpenter_config = var.karpenter_config
  eks_managed_node_groups = var.eks_managed_node_groups
  map_users = var.map_users
  map_accounts = var.map_accounts
  nginx_controller_service_type = var.nginx_controller_service_type
}
