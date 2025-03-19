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

  domain_name = "dev.zivoosh.online"



###############################################################################
# EKS
###############################################################################
  eks_enabled = true
  k8s_version = "1.27"
  eks_managed_node_groups = {}

  enable_aws_load_balancer_controller = true
  enable_aws_efs_csi_driver = true
  enable_metrics_server = false
  enable_kube_prometheus_stack = false
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
    "system" = {
      tainted    = true    # Marks nodes with a taint to prevent regular workloads from scheduling
      core       = true    # Identifies this as a core system component provisioner
      disruption = true    # disruption of these nodes during maintenance
      arc        = false   # Disables AWS Resource Controller integration
      amiFamily  = "AL2023" # Uses Amazon Linux 2023 as the node AMI
      labels = {
        "nodepool" = "system"
      }
      instance_category = {
        operator = "In"
        values   = ["t"]  
      }
      instance_cpu = {
        operator = "In"
        values   = ["4"]  
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
      taint = {
        key    = "system"
        effect = "NoSchedule"
      }
      limits = {
        cpu               = "8"
        memory            = "16Gi"
        ephemeral_storage = "20Gi"
      }
    }

    "general" = {
      tainted    = false
      core       = false
      disruption = true
      arc        = false
      amiFamily  = "AL2023"
      labels = {
        "nodepool" = "general"
      }
      instance_category = {
        operator = "In"
        values   = ["t"]  
      }
      instance_cpu = {
        operator = "In"
        values   = ["2"]  
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
      taint = {
        key    = "system"
        effect = "NoSchedule"
      }
      limits = {
        cpu               = "4"
        memory            = "8Gi"
        ephemeral_storage = "20Gi"
      }
    }
  }
}
