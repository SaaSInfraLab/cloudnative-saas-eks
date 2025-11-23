# =============================================================================
# DEV ENVIRONMENT - INFRASTRUCTURE DEPLOYMENT
# =============================================================================
# This root module directly calls the Terraform-modules infrastructure module.
# Architecture: CloudNative-saas-eks → Terraform-modules → AWS Resources
#
# Configuration values come from ../infrastructure.tfvars
# Backend configuration comes from backend-{env}.tfbackend files
# =============================================================================

locals {
  # Transform project_name + environment into cluster_name
  cluster_name = "${var.project_name}-${var.environment}"
}

# =============================================================================
# INFRASTRUCTURE MODULE (from Terraform-modules repo)
# =============================================================================
# Direct call to Terraform-modules repository on GitHub
# This module orchestrates: VPC, EKS, IAM, Security, Monitoring
# =============================================================================

module "infrastructure" {
  source = "github.com/SaaSInfraLab/Terraform-modules//infrastructure?ref=main"
  
  # Core configuration
  aws_region  = var.aws_region
  environment = var.environment
  
  # Cluster configuration
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  
  cluster_endpoint_config = {
    private_access      = var.cluster_endpoint_private_access
    public_access       = var.cluster_endpoint_public_access
    public_access_cidrs = ["0.0.0.0/0"]
  }
  
  # VPC configuration
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
  # Node group configuration (transform simple vars into complex object)
  node_group_config = {
    instance_types = var.node_instance_types
    capacity_type  = "ON_DEMAND"
    disk_size      = var.node_disk_size
    ami_type       = "AL2023_x86_64_STANDARD"
    scaling_config = {
      desired_size = var.node_desired_size
      max_size     = var.node_max_size
      min_size     = var.node_min_size
    }
  }
  
  # Monitoring configuration
  enable_monitoring  = var.enable_container_insights
  log_retention_days = var.log_retention_days
  enable_flow_logs   = var.enable_flow_logs
  
  # Security configuration
  enable_encryption = true
  
  # Cluster access configuration
  cluster_access_principals         = var.cluster_access_principals
  cluster_access_config             = var.cluster_access_config
  auto_include_executor             = var.auto_include_executor
  create_eks_access_roles           = var.create_eks_access_roles
  eks_admin_trusted_principals      = var.eks_admin_trusted_principals
  eks_developer_trusted_principals  = var.eks_developer_trusted_principals
  eks_viewer_trusted_principals     = var.eks_viewer_trusted_principals
}

