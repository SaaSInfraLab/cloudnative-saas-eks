# Multi-Tenant SaaS on EKS - Dev Environment

Simple deployment of a multi-tenant SaaS platform on AWS EKS with 2 namespaces (platform + analytics).

## Quick Start

### 1. Deploy Infrastructure

```bash
cd infrastructure
terraform init
terraform apply -var-file="../infrastructure.tfvars"
```

**Duration**: 15-20 minutes

### 2. Deploy Tenants (2 namespaces)

```bash
cd ../tenants
terraform init
terraform apply -var-file="../tenants.tfvars"
```

**Duration**: 2-5 minutes

### 3. Update Kubeconfig

```bash
aws eks update-kubeconfig --name saas-infra-lab-dev --region us-east-1
kubectl get nodes
```

### 4. Deploy Applications

```bash
# Platform namespace
kubectl apply -k ../../sample-saas-app/k8s/namespace-platform

# Analytics namespace
kubectl apply -k ../../sample-saas-app/k8s/namespace-analytics
```

## Configuration

- **Infrastructure**: `infrastructure.tfvars` - Cluster, nodes, RDS settings
- **Tenants**: `tenants.tfvars` - Namespace configuration (2 tenants)

## Cost

- **3 × t3.micro nodes**: ~$22.50/month (24/7) or scale down to 1 node (~$7.50/month)
- **RDS t3.micro**: ~$15/month (optional, recommended)
- **Total**: ~$37.50/month (with RDS) or ~$22.50/month (without RDS)

## Cleanup

```bash
cd tenants && terraform destroy -var-file="../tenants.tfvars"
cd ../infrastructure && terraform destroy -var-file="../infrastructure.tfvars"
```
