# Multi-Tenant SaaS on EKS - Dev Environment

This directory contains the Terraform code for deploying a multi-tenant SaaS platform on AWS EKS.

## 🎯 Single Source of Truth

**This repository contains ALL infrastructure configuration - code AND configs.**

- **Terraform code**: `infrastructure/` and `tenants/` directories
- **Configuration files**: `config/` directory (tfvars and backend configs)
- **DevOps engineers edit configs here** - this is the single source of truth

## Automated Deployment

Infrastructure is automatically deployed via GitHub Actions in the [Gitops-pipeline](https://github.com/SaaSInfraLab/Gitops-pipeline) repository.

### For Automated Deployments

1. **Configuration**: Edit `config/*.tfvars` files in this repository
2. **Commit and Push**: Changes trigger deployment via GitOps pipeline
3. **Deployment**: GitOps pipeline clones this repo and applies changes
4. **Outputs**: Terraform outputs are automatically captured in GitOps repo's `infra_version.yaml`

The GitOps repository provides:
- Deployment scripts (`scripts/deploy.sh`, `scripts/destroy.sh`)
- GitHub Actions workflows for automated deployment
- ArgoCD manifests for application deployment

## Manual Deployment (Development Only)

If you need to deploy manually for development/testing:

### Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- kubectl
- Configuration files from the GitOps repository

### 1. Deploy Infrastructure

```bash
cd infrastructure
terraform init -backend-config=../config/infrastructure/backend-dev.tfbackend
terraform apply -var-file=../config/common.tfvars -var-file=../config/infrastructure.tfvars
```

**Duration**: 15-20 minutes

### 2. Deploy Tenants

```bash
cd ../tenants
terraform init -backend-config=../config/tenants/backend-dev.tfbackend
terraform apply -var-file=../config/common.tfvars -var-file=../config/tenants.tfvars
```

**Duration**: 2-5 minutes

This automatically creates:
- `platform` and `analytics` namespaces
- `backend-config` ConfigMap (with RDS endpoint from infrastructure)
- `postgresql-secret` and `backend-secret` Secrets (credentials read from AWS Secrets Manager)
- Resource quotas, network policies, and RBAC for each tenant

### 3. Update Kubeconfig

```bash
aws eks update-kubeconfig --name saas-infra-lab-dev --region us-east-1
kubectl get nodes
```

## Configuration

Configuration files are in this repository (`config/` directory):
- **Common**: `config/common.tfvars` - Shared values (AWS, project, tags, GitHub repos)
- **Infrastructure**: `config/infrastructure.tfvars` - Cluster, nodes, RDS settings
- **Tenants**: `config/tenants.tfvars` - Namespaces and database credentials
- **Backend configs**: `config/infrastructure/backend-dev.tfbackend` and `config/tenants/backend-dev.tfbackend`

**Important**: Database credentials are automatically read from AWS Secrets Manager. The tenants Terraform configuration automatically retrieves the actual RDS password from AWS Secrets Manager for consistency.

## Multi-Tenant Setup

- **platform**: Main tenant namespace
- **analytics**: Second tenant namespace

Both namespaces share the same RDS PostgreSQL database but are isolated with:
- Network policies
- Resource quotas
- RBAC

## Cost

- **2 × m7i-flex.large EKS nodes**: Free tier eligible (1 vCPU, 8GB RAM each)
- **RDS db.t4g.micro**: ~$15/month (ARM-based, free tier eligible)
- **Total**: ~$15-20/month (24/7) or within free tier if used part-time

**Note**: The configuration uses `m7i-flex.large` nodes which are free tier eligible and provide better pod capacity (~29 pods/node) compared to t3.micro (4 pods/node).

## Cleanup

### Automated Cleanup

Use the destroy workflow in the GitOps repository (requires confirmation).

### Manual Cleanup

```bash
cd tenants && terraform destroy -var-file="../config/common.tfvars" -var-file="../config/tenants.tfvars"
cd ../infrastructure && terraform destroy -var-file="../config/common.tfvars" -var-file="../config/infrastructure.tfvars"
```
