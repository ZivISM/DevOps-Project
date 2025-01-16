module "cluster" {
  source = "modules/cluster"
  environment = var.environment
  vpc_cidr = module.network.vpc_cidr
  project = var.project
  karpenter_tag = var.karpenter_tag
  enable_karpenter = var.enable_karpenter
  fargate_additional_profiles = var.fargate_additional_profiles
}

module "karpenter" {
  source = "modules/karpenter"
  environment = var.environment
  project = var.project
  karpenter_tag = var.karpenter_tag
  enable_karpenter = var.enable_karpenter
  karpenter_config = var.karpenter_config
}

module "eks-blueprints" {
  source = "modules/eks-blueprints"
  project = var.project
  aws_region = var.aws_region
}

module "argocd" {
  source = "modules/argocd"
  domain_name = var.domain_name
  github_repo = var.github_repo
}


module "resources" {
  source = "modules/resources"
  project = var.project
  environment = var.environment
  domain_name = var.domain_name
  nginx_controller_service_type = var.nginx_controller_service_type
}