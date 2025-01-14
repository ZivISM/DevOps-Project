variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "eks-cluster"
}

variable "app_name" {
  default = "myapp"
}


variable "ssh-key" {
    default = "zivoosh-key"
}


variable "domain_name" {
  description = "The domain name for the application"
  default     = "zivoosh.online"
}


variable "nginx_controller_service_type" {
default = "LoadBalancer"
}


variable "email" {
  default = "zivismailov@gmail.com"
}


###############################################################################
# Best Practices
###############################################################################

# GENERAL
variable "project" {
  description = "Name of the project - this is used to generate names for resources"
  type        = string
}

variable "environment" {
  description = "The main environment this cluster represents"
  type        = string
}
variable "additional_environments" {
  description = "The environments we are creating in this cluster - used to generate names for resource"
  type        = list(string)
  default     = []

}
variable "additional_cerberus_environments" {
  description = "The environments we are creating in this cluster - used to generate names for resource"
  type        = list(string)
  default     = []

}

variable "tags" {
  description = "List of tags to assign to resources created in this module"
  type        = map(any)
}

variable "aws_region" {
  description = "This is used to define where resources are created and used"
  type        = string
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
variable "enable_cluster_autoscaler" {
  description = "Dictates whether the cluster autoscaler will be installed"
  type        = bool

}

variable "enable_aws_efs_csi_driver" {
  description = "Dictates whether the EFS CSI Driver will be installed"
  type        = bool
}

# KARPENTER

variable "enable_karpenter" {
  description = "Dictates whether Karpenter will be installed"
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

# variable "cerberus_enabled" {
#   type        = bool
#   description = "Var to create drachtio infra"
# }
variable "certmanager_enabled" {
  type        = bool
  description = "Var to create drachtio infra"
}

variable "karpenter_config" {
  description = "Configuration for karpenter node pools"
  type = map(object({
    tainted    = optional(bool)
    core       = optional(bool)
    disruption = optional(bool)
    arc        = optional(bool)
    amiFamily  = string
    instance_category = object({
      operator = string
      values   = list(string)
    })
    instance_cpu = object({
      operator = string
      values   = list(string)
    })
    instance_hypervisor = object({
      operator = string
      values   = list(string)
    })
    instance_generation = object({
      operator = string
      values   = list(string)
    })
    capacity_type = object({
      operator = string
      values   = list(string)
    })

    instance_family = optional(object({
      operator  = string
      values    = optional(list(string))
      minValues = optional(number)
    }))

    limits = object({
      cpu               = string
      memory            = string
      ephemeral_storage = string
    })
  }))
  default = {}

}

variable "base_url" {
  description = "Organization base url"
  type        = string
}



# DATADOG 
# variable "datadog_enabled" {
#   description = "Enable monitoring with Datadog"
#   type        = bool
# }

# # GroundCover
# variable "groundcover_enabled" {
#   description = "Enable monitoring with GroundCover"
#   type        = bool
# }