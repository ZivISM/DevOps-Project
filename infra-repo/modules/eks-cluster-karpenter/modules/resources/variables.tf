variable "project" {
  description = "Name of the project - this is used to generate names for resources"
  type        = string
}

variable "environment" {
  description = "The main environment this cluster represents"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the application"
  default     = "zivoosh.online"
}

variable "nginx_controller_service_type" {
default = "LoadBalancer"
}
