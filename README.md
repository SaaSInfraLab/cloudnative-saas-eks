# 🚀 CloudNative SaaS EKS - Complete Reference Architecture

![Platform Architecture](https://img.shields.io/badge/AWS-EKS-FF9900?style=for-the-badge&logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=for-the-badge&logo=terraform)
![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?style=for-the-badge&logo=kubernetes)
![Multi-Tenant](https://img.shields.io/badge/Architecture-Multi--Tenant-success?style=for-the-badge)

> **🌟 FLAGSHIP PROJECT** - Production-ready, multi-tenant SaaS infrastructure on AWS EKS. Complete solution with infrastructure orchestration, multi-tenant provisioning, and working examples.

## 🎯 Overview

This is the **main reference architecture** that orchestrates all modules to build a complete multi-tenant SaaS platform on AWS EKS. It provides a production-ready foundation with:

- ✅ **Complete Infrastructure Orchestration** - Deploys VPC, EKS cluster, IAM, security, and monitoring
- ✅ **Multi-Tenant Provisioning** - Automated tenant namespace creation with isolation and quotas
- ✅ **Working Examples** - Complete deployment configurations ready to use
- ✅ **Pure Terraform** - No helper scripts required, standard Terraform workflow

---

## 🏗️ Architecture

```
CloudNative-saas-eks (Configuration Repo)
    ↓ calls
Terraform-modules (Module Library Repo - GitHub)
    ↓ creates
AWS Resources (EKS, VPC, IAM, etc.)
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI (configured with credentials)
- Terraform >= 1.0
- kubectl >= 1.32
- Git

### Deployment

```bash
# Clone the repository
git clone https://github.com/SaaSInfraLab/cloudnative-saas-eks.git
cd cloudnative-saas-eks

# Phase 1: Deploy Infrastructure
cd examples/dev-environment/infrastructure
terraform init -backend-config=backend-dev.tfbackend
terraform plan -var-file="../infrastructure.tfvars"
terraform apply -var-file="../infrastructure.tfvars"

# Phase 2: Deploy Tenants
cd ../tenants
terraform init -backend-config=backend-dev.tfbackend
terraform plan -var-file="../tenants.tfvars"
terraform apply -var-file="../tenants.tfvars"

# Verify deployment
aws eks update-kubeconfig --name <cluster-name> --region <region>
kubectl get nodes
kubectl get namespaces
```

**Expected Duration**: Infrastructure: 15-20 minutes | Tenants: 2-5 minutes

For detailed instructions, see [examples/dev-environment/README.md](examples/dev-environment/README.md).

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
    name               = "data-team"
    namespace          = "data"
    cpu_limit          = "10"
    memory_limit       = "20Gi"
    pod_limit          = 150
    storage_limit      = "100Gi"
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

### Infrastructure Variables

Edit `examples/dev-environment/infrastructure.tfvars` to customize:
- Cluster version
- Node instance types and sizes
- VPC CIDR block
- Monitoring settings
- Cluster access configuration

### Tenant Configuration

Edit `examples/dev-environment/tenants.tfvars` to customize:
- Tenant names and namespaces
- Resource quotas (CPU, memory, storage)
- Network policy settings
- Number of tenants

**Database Credentials**: The tenants Terraform automatically reads database credentials from AWS Secrets Manager (created during infrastructure deployment). The `db_password` in `tenants.tfvars` is only used as a fallback, ensuring consistency between RDS and Kubernetes secrets.

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

- **Terraform Modules** - Reusable infrastructure modules ([Terraform-modules](https://github.com/SaaSInfraLab/Terraform-modules))
- **This Repository** - Complete orchestration and examples

---

<div align="center">

## 🌟 Star this repository if it helped you build better SaaS infrastructure! 🌟

[![GitHub stars](https://img.shields.io/github/stars/SaaSInfraLab/cloudnative-saas-eks?style=social)](https://github.com/SaaSInfraLab/cloudnative-saas-eks/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/SaaSInfraLab/cloudnative-saas-eks?style=social)](https://github.com/SaaSInfraLab/cloudnative-saas-eks/network/members)

**Built with ❤️ by the SaaSInfraLab community**

</div>
