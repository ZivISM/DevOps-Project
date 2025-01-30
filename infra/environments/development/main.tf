module "infrastructure" {
  source      = "../../modules"

###############################################################################
# GENERAL
###############################################################################
  environment = "development"
  environment_short = "dev"
  project = "habitspace"
  aws_region = "us-east-1"
  tags = {
  "Project" = "habitspace"
  "Environment" = "Development"
  }
  
###############################################################################
# NETWORK
###############################################################################
  vpc_cidr = "10.0.0.0/16"
  num_zones = 2
  enable_nat_gateway = true
  single_nat_gateway = true

  domain_name = "habits.dev.zivoosh.online"

  github_repo = "https://github.com/ZivISM/DevOps-Project.git"


###############################################################################
# EKS
###############################################################################
  eks_enabled = true
  k8s_version = "1.27"
  eks_managed_node_groups = {}

  enable_aws_load_balancer_controller = true
  enable_aws_efs_csi_driver = true
  enable_metrics_server = true
  enable_kube_prometheus_stack = true
  map_users = [
    {
      userarn  = "arn:aws:iam::123456789012:user/localadmin"
      username = "localadmin"
      groups   = ["system:masters"]
    }
  ]
  map_accounts = ["123456789012"] # Main AWS account ID
  map_roles = [
    {
      rolearn  = "arn:aws:iam::123456789012:role/eks-admin"
      username = "eks-admin" 
      groups   = ["system:masters"]
    }
  ]

###############################################################################
# KARPENTER 
###############################################################################
  enable_karpenter = true

  fargate_additional_profiles = {}

  karpenter_tag = {
    key = "karpenter.sh/discovery"
    value = "dev"
  }

  nginx_controller_service_type = "LoadBalancer"

###############################################################################
# KARPENTER CONFIG (EC2NC + NODEPOOLS)
###############################################################################

  karpenter_config = {
    "system-critical" = {
      tainted    = true    # Marks nodes with a taint to prevent regular workloads from scheduling
      core       = true    # Identifies this as a core system component provisioner
      disruption = true    # disruption of these nodes during maintenance
      arc        = false   # Disables AWS Resource Controller integration
      amiFamily  = "AL2023" # Uses Amazon Linux 2023 as the node AMI
      labels = {
        "karpenter.sh/nodepool" = "system-critical"
      }
      instance_category = {
        operator = "In"
        values   = ["t"]  # General purpose for system components
      }
      instance_cpu = {
        operator = "In"
        values   = ["4"]  # Moderate CPU sizes
      }
      instance_hypervisor = {
        operator = "In"
        values   = ["nitro"]
      }
      instance_generation = {
        operator = "Gt"
        values   = ["2"]
      }
      capacity_type = {
        operator = "In"
        values   = ["spot"] 
      }
      instance_family = {
        operator = "In"
        values   = ["t"]
        minValues = 1
      }
      limits = {
        cpu               = "50"
        memory            = "50Gi"
        ephemeral_storage = "20Gi"
      }
    }

    "general-workload" = {
      tainted    = false
      core       = false
      disruption = true
      arc        = false
      amiFamily  = "AL2023"
      labels = {
        "karpenter.sh/nodepool" = "general-workload"
      }
      instance_category = {
        operator = "In"
        values   = ["t"]  # Mix of burstable and general purpose
      }
      instance_cpu = {
        operator = "In"
        values   = ["2"]  # Flexible CPU sizes
      }
      instance_hypervisor = {
        operator = "In"
        values   = ["nitro"]
      }
      instance_generation = {
        operator = "Gt"
        values   = ["2"]
      }
      capacity_type = {
        operator = "In"
        values   = ["spot"]  
      }
      instance_family = {
        operator = "In"
        values   = ["t3"]
        minValues = 3
      }
      limits = {
        cpu               = "35"
        memory            = "35Gi"
        ephemeral_storage = "20Gi"
      }
    }
  }
}
