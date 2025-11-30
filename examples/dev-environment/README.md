# Multi-Tenant SaaS on EKS - Dev Environment

Deploy a multi-tenant SaaS platform on AWS EKS with 2 namespaces (platform + analytics).

## Quick Start

### 1. Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform apply -var-file="../infrastructure.tfvars"
```

**Duration**: 15-20 minutes

### 2. Deploy Tenants

```bash
cd ../tenants
terraform init
terraform apply -var-file="../tenants.tfvars"
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

### 4. Deploy Applications

```bash
kubectl apply -k ../../../Sample-saas-app/k8s/namespace-platform
kubectl apply -k ../../../Sample-saas-app/k8s/namespace-analytics
```

## Configuration

- **Infrastructure**: `infrastructure.tfvars` - Cluster, nodes, RDS settings
- **Tenants**: `tenants.tfvars` - Namespaces and database credentials

**Important**: Database credentials are automatically read from AWS Secrets Manager. The `db_password` in `tenants.tfvars` is used as a fallback if Secrets Manager is not available. The tenants Terraform configuration automatically retrieves the actual RDS password from AWS Secrets Manager for consistency.

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

```bash
cd tenants && terraform destroy -var-file="../tenants.tfvars"
cd ../infrastructure && terraform destroy -var-file="../infrastructure.tfvars"
```
