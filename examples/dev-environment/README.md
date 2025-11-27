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
- `postgresql-secret` and `backend-secret` Secrets

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

**Important**: `db_password` in `tenants.tfvars` must match `db_password` in `infrastructure.tfvars`.

## Multi-Tenant Setup

- **platform**: Main tenant namespace
- **analytics**: Second tenant namespace

Both namespaces share the same RDS PostgreSQL database but are isolated with:
- Network policies
- Resource quotas
- RBAC

## Cost

- **3 × t3.micro EKS nodes**: ~$22.50/month (or ~$7.50/month with 1 node)
- **RDS db.t3.micro**: ~$15/month
- **Total**: ~$37.50/month (24/7) or within free tier if used part-time

## Cleanup

```bash
cd tenants && terraform destroy -var-file="../tenants.tfvars"
cd ../infrastructure && terraform destroy -var-file="../infrastructure.tfvars"
```
