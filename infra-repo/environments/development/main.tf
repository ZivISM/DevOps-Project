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

module "eks" {
  source = "../../modules/eks"
  cluster_name = var.cluster_name
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  environment = var.environment
}
