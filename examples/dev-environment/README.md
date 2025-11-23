# Dev Environment Example

Self-contained Terraform configurations for deploying the CloudNative SaaS EKS platform in a development environment.

## Architecture

```
CloudNative-saas-eks (Configuration Repo)
    ↓ calls
Terraform-modules (Module Library Repo - GitHub)
    ↓ creates
AWS Resources (EKS, VPC, IAM, etc.)
```

## Structure

```
dev-environment/
├── infrastructure/              # Infrastructure deployment (self-contained root module)
│   ├── main.tf                # Calls Terraform-modules//infrastructure
│   ├── variables.tf           # Variable declarations
│   ├── terraform.tf           # Provider requirements
│   ├── outputs.tf             # Output values
│   └── backend-*.tfbackend    # Environment-specific backend configs
│
├── tenants/                    # Tenants deployment (self-contained root module)
│   ├── main.tf                # Calls Terraform-modules//tenants
│   ├── variables.tf           # Variable declarations
│   ├── terraform.tf           # Provider requirements
│   ├── outputs.tf             # Output values
│   └── backend-*.tfbackend   # Environment-specific backend configs
│
├── infrastructure.tfvars      # Infrastructure configuration
├── tenants.tfvars            # Tenants configuration
└── README.md                  # This file
```

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- kubectl >= 1.28
- S3 bucket: `saas-infra-lab-terraform-state`
- DynamoDB table: `terraform-state-lock`

## Deployment

### Phase 1: Deploy Infrastructure

```bash
cd infrastructure

# Initialize Terraform
terraform init -backend-config=backend-dev.tfbackend

# Review plan
terraform plan -var-file="../infrastructure.tfvars"

# Deploy
terraform apply -var-file="../infrastructure.tfvars"
```

**Expected Duration**: 15-20 minutes

### Phase 2: Deploy Tenants

```bash
cd ../tenants

# Initialize Terraform
terraform init -backend-config=backend-dev.tfbackend

# Review plan
terraform plan -var-file="../tenants.tfvars"

# Deploy
terraform apply -var-file="../tenants.tfvars"
```

**Expected Duration**: 2-5 minutes

## Configuration

### Infrastructure

Edit `infrastructure.tfvars` to customize:
- Cluster version
- Node instance types and sizes
- VPC CIDR block
- Monitoring settings

### Tenants

Edit `tenants.tfvars` to customize:
- Tenant names and namespaces
- Resource quotas (CPU, memory, storage)
- Network policy settings

## Verification

```bash
# Get cluster name
cd infrastructure
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw aws_region)

# Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verify
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
kubectl get quota --all-namespaces
kubectl get networkpolicies --all-namespaces
```

## Cost Optimization

- **t3.micro** instances (free tier compatible)
- **2 nodes** by default
- **7-day log retention**
- **Monitoring disabled** by default

**Estimated Monthly Cost**: ~$75-100 (using free tier)

## Cleanup

```bash
# Destroy tenants first
cd tenants
terraform destroy -var-file="../tenants.tfvars"

# Then destroy infrastructure
cd ../infrastructure
terraform destroy -var-file="../infrastructure.tfvars"
```

## Troubleshooting

### Backend Configuration Issues
- Use `.tfbackend` files instead of `backend.tf` in child modules
- Reinitialize: `terraform init -backend-config=backend-dev.tfbackend`

### Module Not Found
- Check GitHub repository: `github.com/SaaSInfraLab/Terraform-modules`
- Verify `ref=main` branch exists
- Check GitHub access permissions

### State Lock Issues
```bash
terraform force-unlock <LOCK_ID>
```

### DNS Lookup Failures
- Tenants module fetches cluster endpoint directly from AWS
- Verify cluster is ACTIVE: `aws eks describe-cluster --name <cluster-name>`

For more troubleshooting, see [Troubleshooting Guide](../../docs/troubleshooting.md).

## Next Steps

- Deploy sample applications to tenant namespaces
- Configure monitoring dashboards
- Set up CI/CD pipelines
- Review [Architecture Documentation](../../docs/architecture.md)
