# =============================================================================
# COMMON CONFIGURATION - Shared Values for Infrastructure and Tenants
# =============================================================================
# This file contains values shared between infrastructure and tenants.
# Both infrastructure.tfvars and tenants.tfvars reference these values.
#
# Usage:
#   terraform apply -var-file="common.tfvars" -var-file="infrastructure.tfvars"
#   terraform apply -var-file="common.tfvars" -var-file="tenants.tfvars"
# =============================================================================

# =============================================================================
# AWS CONFIGURATION
# =============================================================================
aws_region = "us-east-1"
# aws_account_id is automatically detected from AWS credentials
# If you need to override, uncomment and set:
# aws_account_id = "123456789012"

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================
project_name = "saas-infra-lab"
environment  = "dev"

# =============================================================================
# TERRAFORM STATE CONFIGURATION
# =============================================================================
# terraform_state_bucket defaults to "{project_name}-terraform-state"
# Uncomment to override:
# terraform_state_bucket = "custom-terraform-state-bucket"

# =============================================================================
# COMMON TAGS
# =============================================================================
common_tags = {
  Project     = "SaaSInfraLab"
  ManagedBy   = "Terraform"
  Environment = "dev"
}

# =============================================================================
# GITHUB REPOSITORY CONFIGURATION
# =============================================================================
# These are set to defaults, but can be overridden if needed
github_org              = "SaaSInfraLab"
terraform_modules_repo  = "Terraform-modules"
gitops_repo             = "Gitops-pipeline"
sample_app_repo         = "Sample-Saas-App"
monitoring_stack_repo   = "Monitoring-stack"

