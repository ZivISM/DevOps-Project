# GENERAL
variable "project" {
  description = "Name of the project - this is used to generate names for resources"
  type        = string
}

variable "environment" {
  description = "The main environment this cluster represents"
  type        = string
}


variable "tags" {
  description = "List of tags to assign to resources created in this module"
  type        = map(any)
}

variable "aws_region" {
  description = "This is used to define where resources are created and used"
  type        = string
}


# BACKEND

variable "bucket" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "key" {
  description = "Path to the state file inside the S3 bucket"
  type        = string
}

variable "dynamodb_table" {
  description = "Name of DynamoDB table for state locking"
  type        = string
}

variable "encrypt" {
  description = "Enable server-side encryption of state file"
  type        = bool
  default     = true
}


# NETWORK

variable "vpc_cidr" {
  description = "Cidr of the vpc we will create in the format of X.X.X.X/16"
  type        = string
}

variable "num_zones" {
  description = "How many zones should we utilize for the eks nodes"
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Dictates if it is one nat gateway or multiple"
  type        = bool

}

variable "enable_nat_gateway" {
  description = "Dictates if nat gateway is enabled or not"
  type        = bool
}

variable "karpenter_tag" {
  description = "Tags used by karpenter"
  type = object({
    key   = string
    value = string
  })

}


# EKS

variable "eks_managed_node_groups" {
  description = "(Optional) set of additional node pools for the cluster"
  type        = any
  default     = {}
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_enabled" {
  description = "Controls the creation of the eks cluster"
  type        = bool

}

variable "k8s_version" {
  description = "K8s version that the cluster will use"
  type        = string

}

variable "cluster_addons" {
  description = "Which EKS cluster addons should be installed and their configuration"
  type        = any

  default = {}

}

variable "enable_aws_load_balancer_controller" {
  description = "Dictates whether the ALB controller will be installed"
  type        = bool

}

# variable "enable_metrics_server" {
#   description = "Dictates whether the metrics server will be installed"
#   type        = bool

# }

# variable "enable_cluster_autoscaler" {
#   description = "Dictates whether the cluster autoscaler will be installed"
#   type        = bool

# }

variable "enable_aws_efs_csi_driver" {
  description = "Dictates whether the EFS CSI Driver will be installed"
  type        = bool
}

# KARPENTER

variable "enable_karpenter" {
  description = "Dictates whether Karpenter will be installed"
  type        = bool

}

variable "certmanager_enabled" {
  description = "Dictates whether certmanager will be installed"
  type        = bool
}

variable "fargate_additional_profiles" {
  description = "Additional Profiles to add to fargate"
  type        = any

}

variable "karpenter_tag" {
  description = "Tags used by karpenter"
  type = object({
    key   = string
    value = string
  })

}

variable "github_repo" {
    default = "https://github.com/ZivISM/DevOps-Project.git"  
}

variable "nginx_controller_service_type" {
  default = "LoadBalancer"
}


