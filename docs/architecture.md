# Architecture Documentation

Complete system architecture, design decisions, and component interactions for the CloudNative SaaS EKS platform.

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Account                          │
│                                                         │
│  ┌────────────────────────────────────────────────┐     │
│  │              VPC (10.0.0.0/16)                 │     │
│  │                                                │     │
│  │  ┌──────────────┐  ┌──────────────┐            │     │
│  │  │ Public Subnet│  │ Public Subnet│            │     │
│  │  │  (10.0.101.x)│  │  (10.0.102.x)│            │     │
│  │  └──────────────┘  └──────────────┘            │     │
│  │                                                │     │
│  │  ┌──────────────────────────────────────────┐  │     │
│  │  │         EKS Control Plane                │  │     │
│  │  └──────────────────────────────────────────┘  │     │
│  │                                                │     │
│  │  ┌──────────────┐  ┌──────────────┐            │     │
│  │  │Private Subnet│  │Private Subnet│            │     │
│  │  │  (10.0.1.x)  │  │  (10.0.2.x)  │            │     │
│  │  │              │  │              │            │     │
│  │  │ ┌──────────┐ │  │ ┌──────────┐ │            │     │
│  │  │ │Node Group│ │  │ │Node Group│ │            │     │
│  │  │ │          │ │  │ │          │ │            │     │ 
│  │  │ │ Pods:    │ │  │ │ Pods:    │ │            │     │
│  │  │ │ -tenant1 │ │  │ │ -tenant2 │ │            │     │
│  │  │ │ -tenant3 │ │  │ │ -platform│ │            │     │
│  │  │ └──────────┘ │  │ └──────────┘ │            │     │
│  │  └──────────────┘  └──────────────┘            │     │
│  └────────────────────────────────────────────────┘     │
│                                                         │
│  ┌────────────────────────────────────────────────┐     │
│  │         CloudWatch (Monitoring & Logs)         │     │
│  └────────────────────────────────────────────────┘     │
│                                                         │
│  ┌────────────────────────────────────────────────┐     │
│  │         IAM (Roles & Policies)                 │     │
│  └────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### Repository Architecture

```
CloudNative-saas-eks (Configuration Repository)
    │
    ├── examples/dev-environment/
    │   ├── infrastructure/          # Self-contained root module
    │   └── tenants/                 # Self-contained root module
    │
    └── docs/                        # Documentation

Terraform-modules (Module Library Repository - GitHub)
    │
    ├── infrastructure/              # Infrastructure module
    └── tenants/                     # Tenants module
```

## Components

### 1. Networking Layer (VPC)

- **VPC**: Custom VPC with configurable CIDR block
- **Subnets**: Public and private subnets across 3 availability zones
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access
- **Route Tables**: Separate routes for public and private subnets
- **VPC Flow Logs**: Network traffic monitoring

### 2. Compute Layer (EKS)
- Managed Kubernetes control plane
- Managed worker nodes (on-demand or spot)
- Auto-scaling based on demand

### 3. Identity & Access (IAM)
- Cluster and node IAM roles
- IRSA (IAM Roles for Service Accounts)
- EKS access roles (Admin, Developer, Viewer)

### 4. Security Layer
- Security groups
- Network policies for pod isolation
- RBAC for Kubernetes resources
- Encryption at rest

### 5. Multi-Tenancy
- Isolated namespaces per tenant
- Resource quotas (CPU, memory, storage, pods)
- Network policies for tenant isolation
- RBAC at namespace level

### 6. Observability
- CloudWatch Container Insights
- VPC Flow Logs
- EKS Control Plane Logs
- Per-tenant resource tracking

## Deployment Phases

### Phase 1: Infrastructure

Deploys core AWS infrastructure:
- VPC and networking components
- EKS cluster and node groups
- IAM roles and policies
- Security groups
- CloudWatch monitoring

**Configuration Location**: `cloudnative-saas-eks/examples/dev-environment/infrastructure/`

### Phase 2: Tenants
- Tenant namespaces
- Resource quotas
- Network policies
- RBAC configurations
- Service accounts with IRSA
- Kubernetes secrets (database credentials from AWS Secrets Manager)
- ConfigMaps (application configuration)

**Configuration Location**: `cloudnative-saas-eks/examples/dev-environment/tenants/`

### Phase 3: Application Deployment (CI/CD)
- Container image builds (ECR)
- Automated deployment via GitHub Actions
- Dynamic secret injection (CSI Secrets Store Driver)
- Health check verification
- Rollout status monitoring

**Repository**: `Sample-saas-app` with GitHub Actions workflows

## Design Decisions

### Two-Phase Deployment
**Rationale**: Clear separation of concerns, infrastructure reuse, independent tenant management, better state management.

### Self-Contained Root Modules
**Rationale**: No wrapper layers, direct module calls, standard Terraform workflow, easy replication.

### Backend Configuration via `.tfbackend` Files
**Rationale**: Prevents conflicts with child modules, environment-specific configurations, explicit backend setup.

### Module Sourcing from GitHub
**Rationale**: Version control, easy updates, separation of concerns, reusable across projects.

### Multi-AZ Deployment
**Rationale**: High availability, fault tolerance, AWS best practice.

### Managed Node Groups
**Rationale**: Simplified management, automatic health monitoring, integrated EKS features.

### Network Policies
**Rationale**: Strong tenant isolation, defense in depth, prevents cross-tenant traffic.

### RDS Security Group Configuration
**Rationale**: EKS pods use the cluster security group for networking, not just the nodes security group. Both security groups must be allowed in RDS security group rules to ensure proper connectivity.

### Secrets Management from AWS Secrets Manager
**Rationale**: 
- Single source of truth for database credentials
- Automatic synchronization between RDS and Kubernetes
- Eliminates manual secret updates
- Ensures consistency across deployments
- Platform namespace uses CSI driver for dynamic injection
- Analytics namespace uses Terraform-managed secrets (also read from Secrets Manager)

### SSL/TLS for Database Connections
**Rationale**: 
- RDS requires SSL connections for security
- Prevents `pg_hba.conf` authentication errors
- Encrypts data in transit
- Required by AWS security best practices
- Configured with `ssl: { rejectUnauthorized: false }` in database connection pool

### Timeout Configuration
**Rationale**:
- **Database Connection Timeout (15s)**: Allows sufficient time for RDS SSL handshake and connection establishment
- **Health Check Wrapper (18s)**: Prevents readiness checks from hanging indefinitely, ensures completion before probe timeout
- **Readiness Probe Timeout (20s)**: Matches health check wrapper, provides buffer for network latency
- **Rollout Timeout (10m)**: Accounts for pod startup, image pull, database connection, and health check retries
- These timeouts work together to ensure reliable deployments even with slow database connections

### Direct AWS Data Source for Cluster Info
**Rationale**: Prevents stale endpoint issues, resilient to remote state inconsistencies, always current.

## Security Model

### Defense in Depth
1. **Network Layer**: Security groups, private subnets, network policies
2. **Identity Layer**: IAM roles, RBAC, service accounts, EKS access entries
3. **Resource Layer**: Resource quotas, pod security standards
4. **Encryption**: Encryption at rest and in transit

### Tenant Isolation
- **Network**: Network policies prevent cross-tenant communication
- **Resources**: Quotas limit resource consumption per tenant
- **Access**: RBAC restricts access to tenant namespaces
- **Identity**: Service accounts with IRSA for AWS resource access

## Scalability

- **Horizontal**: Auto-scaling node groups, Kubernetes HPA/VPA, add tenants without infrastructure changes
- **Vertical**: Configurable instance types, storage per node, adjustable tenant quotas

## Cost Optimization

- **Development**: t3.micro/t3.small (free tier compatible)
- **Production**: t3.medium/t3.large with spot instances
- **Strategies**: Auto-scaling, spot instances (up to 90% savings), right-sizing

## High Availability

- Multi-AZ deployment across 3 availability zones
- Nodes spread across AZs
- Managed control plane (99.95% SLA)
- Terraform state management and backups

## Monitoring & Observability

- Cluster health and capacity metrics
- Node and pod resource usage
- Tenant resource consumption
- Network traffic analysis
- EKS control plane logs

## Future Enhancements

- GitOps integration (Flux CD)
- Service mesh (Istio)
- Advanced monitoring (Prometheus/Grafana)
- Multi-region deployment
