# =============================================================================
# VARIABLE DECLARATIONS
# =============================================================================
# These variables match the structure in ../infrastructure.tfvars
# =============================================================================

# Core Configuration
variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "saas-infra-lab"

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
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project    = "SaaSInfraLab"
    ManagedBy  = "Terraform"
    Repository = "https://github.com/SaaSInfraLab/cloudnative-saas-eks"
  }
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# EKS Cluster Configuration
variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to cluster endpoint"
  type        = bool
  default     = true
}

# Node Group Configuration
variable "node_instance_types" {
  description = "List of EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 20
}

# Spot Instances (Optional)
variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "spot_instance_types" {
  description = "List of EC2 instance types for spot instances"
  type        = list(string)
  default     = ["t3.micro", "t3a.micro"]
}

variable "spot_desired_size" {
  description = "Desired number of spot instances"
  type        = number
  default     = 0
}

variable "spot_min_size" {
  description = "Minimum number of spot instances"
  type        = number
  default     = 0
}

variable "spot_max_size" {
  description = "Maximum number of spot instances"
  type        = number
  default     = 2
}

# Monitoring and Logging
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

# EKS Cluster Access Management
variable "create_eks_access_roles" {
  description = "Whether to create IAM roles for EKS cluster access"
  type        = bool
  default     = true
}

variable "eks_admin_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Admin role"
  type        = list(string)
  default     = []
}

variable "eks_developer_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Developer role"
  type        = list(string)
  default     = []
}

variable "eks_viewer_trusted_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Viewer role"
  type        = list(string)
  default     = []
}

variable "cluster_access_principals" {
  description = "List of IAM principal ARNs that should have cluster access"
  type        = list(string)
  default     = []
}

variable "cluster_access_config" {
  description = "Map of principal ARN to access configuration"
  type = map(object({
    policy_arn = string
    access_scope = object({
      type       = string
      namespaces = list(string)
    })
  }))
  default = {}
}

variable "auto_include_executor" {
  description = "Automatically include the IAM principal running Terraform in cluster access"
  type        = bool
  default     = true
}

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

variable "db_password" {
  description = "Password for RDS PostgreSQL database"
  type        = string
  sensitive   = true
  default     = "changeme"  # Change this in infrastructure.tfvars
}

