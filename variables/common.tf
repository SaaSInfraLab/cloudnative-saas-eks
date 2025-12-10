# =============================================================================
# COMMON VARIABLES - Centralized Configuration
# =============================================================================
# This file contains all common variables used across the infrastructure.
# These variables should be set in infrastructure-config/{env}/*.tfvars files
# in the GitOps repository (Gitops-pipeline).

# =============================================================================
# AWS CONFIGURATION
# =============================================================================

variable "aws_account_id" {
  description = "AWS Account ID - Automatically detected if not provided"
  type        = string
  default     = null

  validation {
    condition     = var.aws_account_id == null || can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be a 12-digit number."
  }
}

variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

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

# =============================================================================
# TERRAFORM STATE CONFIGURATION
# =============================================================================

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
  default     = null
}

# Computed: terraform_state_bucket will default to {project_name}-terraform-state
locals {
  state_bucket = coalesce(var.terraform_state_bucket, "${var.project_name}-terraform-state")
}

# =============================================================================
# IAM PRINCIPALS CONFIGURATION
# =============================================================================

variable "eks_admin_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Admin role"
  type        = list(string)
  default     = []
}

variable "eks_developer_principals" {
  description = "List of IAM principal ARNs that can assume the EKS Developer role"
  type        = list(string)
  default     = []
}

variable "eks_viewer_principals" {
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

# =============================================================================
# COMMON TAGS
# =============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project    = "SaaSInfraLab"
    ManagedBy  = "Terraform"
    Repository = "https://github.com/SaaSInfraLab/cloudnative-saas-eks"
  }
}

# =============================================================================
# GITHUB REPOSITORY CONFIGURATION
# =============================================================================

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "SaaSInfraLab"
}

variable "terraform_modules_repo" {
  description = "Terraform modules repository name"
  type        = string
  default     = "Terraform-modules"
}

variable "gitops_repo" {
  description = "GitOps pipeline repository name"
  type        = string
  default     = "Gitops-pipeline"
}

variable "sample_app_repo" {
  description = "Sample SaaS application repository name"
  type        = string
  default     = "Sample-Saas-App"
}

variable "monitoring_stack_repo" {
  description = "Monitoring stack repository name"
  type        = string
  default     = "Monitoring-stack"
}

# Computed GitHub URLs
locals {
  github_base_url     = "https://github.com/${var.github_org}"
  terraform_modules_url = "${local.github_base_url}/${var.terraform_modules_repo}"
  gitops_repo_url     = "${local.github_base_url}/${var.gitops_repo}"
  sample_app_repo_url = "${local.github_base_url}/${var.sample_app_repo}"
  monitoring_stack_url = "${local.github_base_url}/${var.monitoring_stack_repo}"
}

