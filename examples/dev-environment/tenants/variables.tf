variable "aws_account_id" {
  description = "AWS Account ID - Automatically detected if not provided"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region where infrastructure is deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project - used for resource naming"
  type        = string
  default     = "saas-infra-lab"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state storage"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

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

variable "tenants" {
  description = "List of tenant configurations for multi-tenancy"
  type = list(object({
    name                  = string
    namespace             = string
    cpu_limit             = string
    memory_limit          = string
    pod_limit             = number
    storage_limit         = string
    enable_network_policy = bool
  }))
  default = []
}

variable "db_user" {
  description = "PostgreSQL database username"
  type        = string
  default     = "taskuser"
}

variable "db_pool_min" {
  description = "Minimum database connection pool size"
  type        = string
  default     = "2"
}

variable "db_pool_max" {
  description = "Maximum database connection pool size"
  type        = string
  default     = "10"
}

variable "jwt_expires_in" {
  description = "JWT token expiration time"
  type        = string
  default     = "24h"
}

variable "metrics_enabled" {
  description = "Enable Prometheus metrics"
  type        = string
  default     = "true"
}
