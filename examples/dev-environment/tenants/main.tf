# =============================================================================
# TENANTS DEPLOYMENT - Complete Configuration
# =============================================================================
# This file contains ALL tenant configuration and calls modules directly.
# All values come from variables defined in cloudnative-saas-eks.
# 
# Note: Data sources, providers, and common locals are defined in app-config.tf
# =============================================================================

locals {
  # Use common variables for GitHub URLs
  terraform_modules_url = "github.com/${var.github_org}/${var.terraform_modules_repo}"

  # Get cluster name from infrastructure phase (defined in app-config.tf)
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name

  # Common tags - single source of truth
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      ProjectName = var.project_name
      Phase       = "Tenants"
    }
  )
}

# =============================================================================
# MULTI-TENANCY MODULE
# =============================================================================

module "multi_tenancy" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/multi-tenancy?ref=testing"

  # Tenant configurations - ALL from cloudnative-saas-eks variables
  tenants = var.tenants

  # Cluster information from infrastructure phase
  cluster_name = local.cluster_name
  aws_region   = var.aws_region

  # Multi-tenancy features
  enable_rbac                = true
  enable_namespace_isolation = true
  enable_service_accounts    = true

  # Tags from cloudnative-saas-eks
  tags = local.common_tags
}
