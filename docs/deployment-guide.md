# Deployment Guide

Step-by-step instructions for deploying the CloudNative SaaS EKS platform using pure Terraform workflow.

## Prerequisites

### Required Tools

- **AWS CLI** - Configured with credentials
- **Terraform** >= 1.0
- **kubectl** >= 1.32
- **Git**
- **Bash** (for scripts)

### AWS Requirements

- AWS Account with appropriate permissions
- IAM user or role with permissions to create:
  - VPC, Subnets, Internet Gateway, NAT Gateway
  - EKS Cluster and Node Groups
  - IAM Roles and Policies
  - Security Groups
  - CloudWatch Logs
  - S3 (for Terraform state)
  - DynamoDB (for state locking)

### Verify Prerequisites

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Terraform version
terraform version
kubectl version --client
```

## Quick Start

### Step 1: Clone Repository

```bash
git clone https://github.com/SaaSInfraLab/cloudnative-saas-eks.git
cd cloudnative-saas-eks
```

### Step 2: Configure S3 Backend (First Time Only)

Before deploying, ensure you have an S3 bucket for Terraform state:

```bash
# Create S3 bucket for state
aws s3 mb s3://saas-infra-lab-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket saas-infra-lab-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 3: Deploy Infrastructure

```bash
cd examples/dev-environment/infrastructure

# Initialize Terraform
terraform init -backend-config=backend-dev.tfbackend

# Review plan
terraform plan -var-file="../infrastructure.tfvars"

# Deploy
terraform apply -var-file="../infrastructure.tfvars"
```

**Expected Duration**: 15-20 minutes

### Step 4: Configure kubectl

```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw aws_region)

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verify connection
kubectl get nodes
kubectl get namespaces
```

### Step 5: Deploy Tenants (Phase 2)

After infrastructure is deployed, deploy tenants:

```bash
# Navigate to tenants directory
cd ../tenants

# Initialize Terraform
terraform init -backend-config=backend-dev.tfbackend

# Review plan
terraform plan -var-file="../tenants.tfvars"
```

# Deploy
terraform apply -var-file="../tenants.tfvars"
```

**Expected Duration**: 2-5 minutes

### Step 6: Verify Deployment

```bash
# Check nodes
kubectl get nodes

# Check namespaces
kubectl get namespaces

# Check resource quotas
kubectl get quota --all-namespaces

# Check network policies
kubectl get networkpolicies --all-namespaces

# Check service accounts
kubectl get serviceaccounts --all-namespaces

# Check tenant resources
kubectl describe quota -n platform
kubectl describe quota -n data
kubectl describe quota -n analytics
```

## Configuration

### Infrastructure Configuration

Edit `examples/dev-environment/infrastructure.tfvars` to customize:

### Tenants

Edit `examples/dev-environment/tenants.tfvars`:
- Tenant names and namespaces
- Resource quotas (CPU, memory, storage)
- Network policy settings

## Environment-Specific Deployment

### Development Environment

```bash
# Dev
terraform init -backend-config=backend-dev.tfbackend

# Staging
terraform init -backend-config=backend-staging.tfbackend

# Production
terraform init -backend-config=backend-prod.tfbackend
```

## Cleanup

```bash
# Destroy tenants first
cd examples/dev-environment/tenants
terraform destroy -var-file="../tenants.tfvars"

# Then destroy infrastructure
cd ../infrastructure
terraform destroy -var-file="../infrastructure.tfvars"
```

## Troubleshooting

See [Troubleshooting Guide](troubleshooting.md) for common issues and solutions.

## Next Steps

- Review [Architecture Documentation](architecture.md)
- Deploy sample applications to tenant namespaces
- Configure monitoring dashboards
- Set up CI/CD pipelines
