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