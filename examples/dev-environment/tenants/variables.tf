# =============================================================================
# VARIABLE DECLARATIONS
# =============================================================================
# These variables match the structure in ../tenants.tfvars
# =============================================================================

variable "aws_region" {
  description = "AWS region where infrastructure is deployed"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
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

