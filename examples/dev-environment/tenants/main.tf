# =============================================================================
# DEV ENVIRONMENT - TENANTS DEPLOYMENT
# =============================================================================
# This root module directly calls the Terraform-modules tenants module.
# Architecture: CloudNative-saas-eks → Terraform-modules → AWS Resources
#
# Configuration values come from ../tenants.tfvars
# Backend configuration comes from backend-{env}.tfbackend files
# =============================================================================

# =============================================================================
# TENANTS MODULE (from Terraform-modules repo)
# =============================================================================
# Direct call to Terraform-modules repository on GitHub
# This module creates: Namespaces, RBAC, Resource Quotas, Network Policies
# =============================================================================

module "tenants" {
  source = "github.com/SaaSInfraLab/Terraform-modules//tenants?ref=main"
  
  # Core configuration
  aws_region  = var.aws_region
  environment = var.environment
  
  # Tenant configurations
  tenants = var.tenants
}

