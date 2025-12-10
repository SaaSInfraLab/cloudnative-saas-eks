# =============================================================================
# TENANTS CONFIGURATION - Dev Environment
# =============================================================================
# This file contains tenant-specific configuration values.
# Common values are in common.tfvars
#
# Usage:
#   terraform apply -var-file="common.tfvars" -var-file="tenants.tfvars"
# =============================================================================

# =============================================================================
# TENANT CONFIGURATION
# =============================================================================
tenants = [
  {
    name                  = "platform"
    namespace             = "platform"
    cpu_limit             = "20"
    memory_limit          = "40Gi"
    pod_limit             = 200
    storage_limit         = "200Gi"
    enable_network_policy = true
  },
  {
    name                  = "analytics"
    namespace             = "analytics"
    cpu_limit             = "15"
    memory_limit          = "30Gi"
    pod_limit             = 180
    storage_limit         = "150Gi"
    enable_network_policy = true
  }
]

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================
# WARNING: Do NOT put database passwords in this file!
# Database credentials are automatically read from AWS Secrets Manager
# which was created during infrastructure deployment.
# 
# The Terraform code will:
# 1. Read RDS credentials from AWS Secrets Manager (created in infrastructure phase)
# 2. Create Kubernetes secrets with the same credentials
# 3. Ensure consistency between RDS and Kubernetes secrets
#
# To update the database password:
# 1. Update the secret in AWS Secrets Manager
# 2. Re-run terraform apply - it will automatically sync to Kubernetes

db_user = "taskuser"
# db_password is removed - use AWS Secrets Manager instead
# The password is stored in: {project_name}-{environment}-rds-credentials-{hash}
# Example: saas-infra-lab-dev-rds-credentials-694eb36771a5df4e

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================
# WARNING: Do NOT put JWT secrets in this file!
# JWT secrets should be stored in AWS Secrets Manager.
# The Terraform code should be updated to read from Secrets Manager.

# jwt_secret is removed - use AWS Secrets Manager instead
# Generate a strong random secret and store it in AWS Secrets Manager
jwt_expires_in  = "24h"
metrics_enabled = "true"
db_pool_min     = "2"
db_pool_max     = "10"

