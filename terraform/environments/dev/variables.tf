# Project Configuration
variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "saas-platform"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "SaaSInfraLab"
    ManagedBy   = "Terraform"
    Repository  = "github.com/SaaSInfraLab/cloudnative-saas-eks"
  }
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# EKS Cluster Configuration
variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to cluster endpoint"
  type        = bool
  default     = true
}

# Node Group Configuration
variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}

# Cost Optimization
variable "enable_spot_instances" {
  description = "Enable spot instances for cost savings"
  type        = bool
  default     = false
}

variable "spot_instance_types" {
  description = "Instance types for spot node group"
  type        = list(string)
  default     = ["t3.medium", "t3a.medium"]
}

variable "spot_desired_size" {
  description = "Desired number of spot instances"
  type        = number
  default     = 2
}

variable "spot_min_size" {
  description = "Minimum number of spot instances"
  type        = number
  default     = 0
}

variable "spot_max_size" {
  description = "Maximum number of spot instances"
  type        = number
  default     = 10
}

# Multi-Tenancy Configuration
variable "enable_multi_tenancy" {
  description = "Enable multi-tenant namespace isolation"
  type        = bool
  default     = true
}

variable "default_tenant_quota" {
  description = "Default resource quota for each tenant namespace"
  type = object({
    cpu_limit      = string
    memory_limit   = string
    pods_limit     = string
    storage_limit  = string
  })
  default = {
    cpu_limit     = "4"
    memory_limit  = "8Gi"
    pods_limit    = "10"
    storage_limit = "50Gi"
  }
}

# Monitoring & Observability
variable "enable_prometheus" {
  description = "Enable Prometheus monitoring stack"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Enable Grafana dashboards"
  type        = bool
  default     = true
}

variable "enable_container_insights" {
  description = "Enable AWS Container Insights"
  type        = bool
  default     = true
}

# Logging
variable "enable_fluent_bit" {
  description = "Enable Fluent Bit for log collection"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
}

# Security
variable "enable_pod_security_policy" {
  description = "Enable Pod Security Standards"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policies for pod isolation"
  type        = bool
  default     = true
}

variable "enable_secrets_encryption" {
  description = "Enable encryption of Kubernetes secrets using AWS KMS"
  type        = bool
  default     = true
}

# Add-ons
variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_external_dns" {
  description = "Enable External DNS for automatic DNS management"
  type        = bool
  default     = false
}

variable "enable_cert_manager" {
  description = "Enable cert-manager for TLS certificate management"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for the application (required if external_dns is enabled)"
  type        = string
  default     = ""
}