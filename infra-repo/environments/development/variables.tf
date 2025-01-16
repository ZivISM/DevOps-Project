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