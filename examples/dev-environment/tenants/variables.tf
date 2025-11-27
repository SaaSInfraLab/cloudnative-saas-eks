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

variable "db_user" {
  description = "PostgreSQL database username"
  type        = string
  default     = "taskuser"
}

variable "db_password" {
  description = "PostgreSQL database password (must match infrastructure.tfvars)"
  type        = string
  sensitive   = true
  default     = "changeme"
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

variable "jwt_secret" {
  description = "JWT secret key for authentication"
  type        = string
  sensitive   = true
  default     = "dev-jwt-secret-key-change-for-production-use-strong-random-key"
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
