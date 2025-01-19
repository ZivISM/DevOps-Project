###############################################################################
# AWS Provider
###############################################################################
provider "aws" {
  region = "us-east-1"
  alias  = "forKarpenter"
}

# Your existing AWS provider (if different region)
provider "aws" {
  region = var.aws_region
}

###############################################################################
# Terraform Providers
###############################################################################
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.18.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.forKarpenter]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27"
    }
  }

  required_version = "~> 1.0"
}

###############################################################################
# Kubernetes Provider
###############################################################################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

###############################################################################
# Kubectl Provider
###############################################################################
provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
# 
###############################################################################
# Helm Provider
###############################################################################
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
