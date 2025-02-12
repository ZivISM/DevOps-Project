##################################################
# GENERAL
##################################################

variable "project" {
  description = "The project this cluster represents"
  type        = string
}

variable "environment" {
  description = "The environment this cluster represents"
  type        = string
}

variable "environment_short" {
  description = "The short name of the environment"
  type        = string
}

# variable "additional_environments" {
#   description = "The additional environments this cluster represents"
#   type        = list(string)
# }

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

##################################################
# NETWORK
##################################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "num_zones" {
  description = "The number of availability zones to use"
  type        = number
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway"
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateways"
  type        = bool
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
}

##################################################
# EKS
##################################################

variable "eks_enabled" {
  description = "Whether to enable EKS"
  type        = bool
}

variable "k8s_version" {
  description = "The Kubernetes version to use"
  type        = string
}

variable "eks_managed_node_groups" {
  description = "The managed node groups to use"
  type        = any
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



variable "cluster_addons" {
  description = "Which EKS cluster addons should be installed and their configuration"
  type        = any

  default = {}

}

variable "enable_aws_load_balancer_controller" {
  description = "Dictates whether the ALB controller will be installed"
  type        = bool

}

variable "enable_metrics_server" {
  description = "Dictates whether the metrics server will be installed"
  type        = bool

}

variable "enable_kube_prometheus_stack" {
  description = "Dictates whether the kube prometheus stack will be installed"
  type        = bool
}


variable "enable_aws_efs_csi_driver" {
  description = "Dictates whether the EFS CSI Driver will be installed"
  type        = bool
}

variable "nginx_controller_service_type" {
  description = "The service type for the nginx controller"
  type        = string
}

##################################################
# KARPENTER
##################################################

variable "enable_karpenter" {
  description = "Whether to enable Karpenter"
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

variable "karpenter_config" {
  description = "Configuration for karpenter node pools"
  type = map(object({
    tainted    = optional(bool)
    core       = optional(bool)
    disruption = optional(bool)
    arc        = optional(bool)
    labels     = optional(map(string))
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

variable "github_repo" {
  description = "The GitHub repository to use"
  type        = string
}