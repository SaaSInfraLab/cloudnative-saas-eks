# 🚀 CloudNative SaaS EKS - Complete Reference Architecture

![Platform Architecture](https://img.shields.io/badge/AWS-EKS-FF9900?style=for-the-badge&logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes)
![Multi-Tenant](https://img.shields.io/badge/Architecture-Multi--Tenant-success?style=for-the-badge)

> **🌟 FLAGSHIP PROJECT** - Production-ready, multi-tenant SaaS infrastructure on AWS EKS. Complete solution with infrastructure orchestration, multi-tenant provisioning, and working examples.

## 🎯 Overview

This is the **single source of truth** for all infrastructure configurations. It orchestrates reusable Terraform modules to build a complete multi-tenant SaaS platform on AWS EKS. It provides a production-ready foundation with:

- ✅ **Complete Infrastructure Orchestration** - Deploys VPC, EKS cluster, IAM, security, and monitoring
- ✅ **Multi-Tenant Provisioning** - Automated tenant namespace creation with isolation and quotas
- ✅ **Working Examples** - Complete deployment configurations ready to use
- ✅ **Pure Terraform** - Standard Terraform workflow, no helper scripts required
- ✅ **Centralized Configuration** - All configs (tfvars, backend) in one place
- ✅ **GitOps Integration** - Automated deployment via GitHub Actions and ArgoCD

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│  cloudnative-saas-eks (Single Source of Truth)          │
│  ├── Configuration Files (config/*.tfvars)               │
│  ├── Terraform Code (examples/dev-environment/)         │
│  └── Backend Configs (config/*/backend-dev.tfbackend)    │
└─────────────────────────────────────────────────────────┘
                    ↓ calls
┌─────────────────────────────────────────────────────────┐
│  Terraform-modules (Module Library - GitHub)             │
│  └── Pure reusable modules only                          │
└─────────────────────────────────────────────────────────┘
                    ↓ creates
┌─────────────────────────────────────────────────────────┐
│  AWS Resources (EKS, VPC, IAM, RDS, ECR, etc.)           │
└─────────────────────────────────────────────────────────┘
                    ↓ managed by
┌─────────────────────────────────────────────────────────┐
│  Gitops-pipeline (Automation Layer)                      │
│  └── GitHub Actions + ArgoCD                            │
└─────────────────────────────────────────────────────────┘
```

**Key Principles:**
- ✅ **cloudnative-saas-eks** = Single source of truth for ALL configurations
- ✅ **Terraform-modules** = Pure reusable modules (no configs)
- ✅ **Gitops-pipeline** = Automation layer (watches and applies changes)

## 🚀 Quick Start

### Prerequisites

- **AWS CLI** - Configured with valid credentials (`aws sts get-caller-identity` should work)
- **Terraform** >= 1.0
- **kubectl** >= 1.32
- **Git**
- **S3 Bucket** - For Terraform state (created automatically or manually)

### Verify Prerequisites

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Terraform version
terraform version

# Check kubectl
kubectl version --client
```

### Deployment

```bash
# Clone the repository
git clone https://github.com/SaaSInfraLab/cloudnative-saas-eks.git
cd cloudnative-saas-eks

# Phase 1: Deploy Infrastructure
cd examples/dev-environment/infrastructure
terraform init -backend-config=../config/infrastructure/backend-dev.tfbackend
terraform plan -var-file=../config/common.tfvars -var-file=../config/infrastructure.tfvars
terraform apply -var-file=../config/common.tfvars -var-file=../config/infrastructure.tfvars

# Phase 2: Deploy Tenants
cd ../tenants
terraform init -backend-config=../config/tenants/backend-dev.tfbackend
terraform plan -var-file=../config/common.tfvars -var-file=../config/tenants.tfvars
terraform apply -var-file=../config/common.tfvars -var-file=../config/tenants.tfvars

# Verify deployment
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw aws_region)
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION
kubectl get nodes
kubectl get namespaces
```

**Expected Duration**: Infrastructure: 15-20 minutes | Tenants: 2-5 minutes

### First-Time Setup

Before deploying, ensure you have an S3 bucket for Terraform state:

```bash
# Create S3 bucket for state (if it doesn't exist)
aws s3 mb s3://saas-infra-lab-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket saas-infra-lab-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking (if it doesn't exist)
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

For detailed instructions, see [examples/dev-environment/README.md](examples/dev-environment/README.md).

## 📁 Repository Structure

```
cloudnative-saas-eks/
├── examples/
│   └── dev-environment/          # Development environment configuration
│       ├── config/                # ⭐ ALL CONFIGURATION FILES (Single Source of Truth)
│       │   ├── common.tfvars      # Shared values (AWS, project, tags, GitHub repos)
│       │   ├── infrastructure.tfvars
│       │   ├── tenants.tfvars
│       │   ├── infrastructure/
│       │   │   └── backend-dev.tfbackend
│       │   └── tenants/
│       │       └── backend-dev.tfbackend
│       ├── infrastructure/       # Infrastructure Terraform code
│       │   ├── main.tf            # Calls modules from Terraform-modules repo
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   └── rds.tf
│       ├── tenants/               # Tenants Terraform code
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── README.md              # Detailed deployment guide
└── docs/                          # Additional documentation
    ├── architecture.md
    ├── deployment-guide.md
    └── troubleshooting.md
```

**Key Points:**
- All configuration files are in `examples/dev-environment/config/`
- Terraform code calls modules from `github.com/SaaSInfraLab/Terraform-modules`
- Backend configs point to S3 for remote state

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Architecture Guide](docs/architecture.md) | Complete system architecture and design decisions |
| [Deployment Guide](docs/deployment-guide.md) | Step-by-step deployment instructions |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and their solutions |
| [Dev Environment Example](examples/dev-environment/README.md) | Complete working example with step-by-step guide |

- **Multi-Tenant Isolation** - Network policies, RBAC, and resource quotas per tenant
- **Enterprise Security** - Encryption, private subnets, IAM integration, IRSA support
- **Cost Optimized** - Free tier compatible, spot instance support, auto-scaling
- **Production Ready** - Multi-AZ deployment, monitoring, follows AWS Well-Architected Framework

## 🎯 Use Cases

### SaaS Platforms
- **Multi-tenant applications** with complete customer isolation
- **Per-customer environments** with resource governance
- **Cost allocation** and usage tracking per tenant

### Enterprise Organizations
- **Department isolation** on shared infrastructure
- **Environment management** (dev/staging/prod)
- **Resource governance** and cost control

### Consulting & Agencies
- **Client-dedicated environments** on shared platform
- **Project-based** resource allocation
- **Rapid provisioning** and teardown

---

## 🏢 Multi-Tenant Configuration

### Default Tenant Setup

```hcl
tenants = [
  {
    name               = "platform"
    namespace          = "platform"
    cpu_limit          = "20"
    memory_limit       = "40Gi"
    pod_limit          = 200
    storage_limit      = "200Gi"
    enable_network_policy = true
  },
  {
    name               = "analytics"
    namespace          = "analytics"
    cpu_limit          = "15"
    memory_limit       = "30Gi"
    pod_limit          = 180
    storage_limit      = "150Gi"
    enable_network_policy = true
  }
]
```

### Tenant Isolation Features

- ✅ **Network Policies** - Prevent cross-tenant traffic
- ✅ **Resource Quotas** - CPU, memory, storage, and pod limits
- ✅ **RBAC** - Namespace-level access control
- ✅ **Service Accounts** - IAM roles for service accounts (IRSA)
- ✅ **Monitoring** - Per-tenant resource usage tracking

---

## 💻 Example Usage

### Deploy to Cluster

```bash
# Update kubeconfig
aws eks update-kubeconfig --name saas-infra-lab-dev --region us-east-1

# Deploy application to tenant namespace
kubectl apply -f my-app.yaml -n analytics

# Verify deployment
kubectl get pods -n analytics
kubectl get quota -n analytics
```

---

## 🔧 Configuration

**All configuration files are located in `examples/dev-environment/config/` directory:**

### Configuration Files

- **`config/common.tfvars`** - Shared values (AWS region, project name, common tags, GitHub repo names)
- **`config/infrastructure.tfvars`** - Infrastructure settings (cluster version, node types, VPC CIDR, monitoring)
- **`config/tenants.tfvars`** - Tenant configuration (namespaces, resource quotas, network policies)
- **`config/infrastructure/backend-dev.tfbackend`** - Terraform state backend for infrastructure
- **`config/tenants/backend-dev.tfbackend`** - Terraform state backend for tenants

### Customization

**Infrastructure Variables** (`config/infrastructure.tfvars`):
- Cluster version and Kubernetes settings
- Node instance types and sizes
- VPC CIDR block and availability zones
- Monitoring and logging settings
- Cluster access configuration

**Tenant Configuration** (`config/tenants.tfvars`):
- Tenant names and namespaces
- Resource quotas (CPU, memory, storage, pods)
- Network policy settings
- Number of tenants

**Database Credentials**: The tenants Terraform automatically reads database credentials from AWS Secrets Manager (created during infrastructure deployment). The `db_password` in `tenants.tfvars` is only used as a fallback, ensuring consistency between RDS and Kubernetes secrets.

### Automated Deployment

Changes to configuration files in this repository are automatically deployed via the [Gitops-pipeline](https://github.com/SaaSInfraLab/Gitops-pipeline) repository, which watches for changes and applies them using GitHub Actions.

---

## 📊 Monitoring & Observability

### Built-in Monitoring

- **CloudWatch Container Insights** - Cluster and pod metrics
- **VPC Flow Logs** - Network traffic analysis
- **EKS Control Plane Logs** - API server, scheduler logs
- **Resource Quotas** - Per-tenant usage tracking

### Access Metrics

```bash
# View cluster metrics
aws cloudwatch get-metric-statistics \
  --namespace ContainerInsights \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=saas-infra-lab-dev

# View tenant resource usage
kubectl top pods --all-namespaces
kubectl describe quota -n <tenant-namespace>
```

---

## 🛡️ Security Best Practices

### Infrastructure Security
- ✅ Encryption at rest (EBS volumes, secrets)
- ✅ Private subnets for worker nodes
- ✅ Security groups with least privilege
- ✅ VPC Flow Logs for network monitoring

### Kubernetes Security
- ✅ Pod Security Standards (replaces deprecated PSPs)
- ✅ Network policies for traffic isolation
- ✅ RBAC for fine-grained access control
- ✅ IAM Roles for Service Accounts (IRSA)

### Compliance
- Follows AWS Well-Architected Framework
- Implements defense in depth
- Audit-ready logging and monitoring

---

## 💰 Cost Optimization

| Environment | Instance Type | Node Count | Estimated Cost |
|-------------|---------------|------------|----------------|
| **Development** | m7i-flex.large | 2 | ~$15-20/month (free tier eligible) |
| **Staging** | t3.medium | 3 | ~$200-300 |
| **Production** | t3.large | 5+ | ~$500-800 |

**Note**: Development environment uses `m7i-flex.large` nodes which are free tier eligible and provide better pod capacity (~29 pods/node) compared to t3.micro (4 pods/node).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **📋 Issues**: [GitHub Issues](https://github.com/SaaSInfraLab/cloudnative-saas-eks/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/SaaSInfraLab/cloudnative-saas-eks/discussions)
- **📖 Documentation**: [docs/](docs/)

## 🌟 Related Projects

This is part of the **SaaSInfraLab** ecosystem:

- **[Terraform-modules](https://github.com/SaaSInfraLab/Terraform-modules)** - Pure reusable infrastructure modules (no configs)
- **[Gitops-pipeline](https://github.com/SaaSInfraLab/Gitops-pipeline)** - Automation layer (GitHub Actions + ArgoCD)
- **[Sample-Saas-App](https://github.com/SaaSInfraLab/Sample-Saas-App)** - Sample application deployed to the platform
- **This Repository** - Single source of truth for all configurations

---

<div align="center">

## 🌟 Star this repository if it helped you build better SaaS infrastructure! 🌟

[![GitHub stars](https://img.shields.io/github/stars/SaaSInfraLab/cloudnative-saas-eks?style=social)](https://github.com/SaaSInfraLab/cloudnative-saas-eks/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SaaSInfraLab/cloudnative-saas-eks?style=social)](https://github.com/SaaSInfraLab/cloudnative-saas-eks/network/members)

**Built with ❤️ by the SaaSInfraLab community**

</div>
