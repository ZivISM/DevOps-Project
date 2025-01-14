# DevOps Project

A complete infrastructure and deployment setup for a three-tier application.

## Structure 

## 🎯 Features

- ✨ AWS EKS Cluster with managed node groups
- 🔄 GitOps with ArgoCD
- 🛡️ Security best practices
- 🔧 Infrastructure automation
- 📊 Monitoring and observability
- 🚀 Auto-scaling with Karpenter

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Git

### Deployment Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

4. **Access ArgoCD**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```









 