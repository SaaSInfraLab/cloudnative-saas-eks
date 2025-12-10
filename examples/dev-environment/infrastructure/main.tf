# =============================================================================
# INFRASTRUCTURE DEPLOYMENT - Complete Configuration
# =============================================================================
# This file contains ALL infrastructure configuration and calls modules directly.
# All values come from variables defined in cloudnative-saas-eks.
# =============================================================================

# Get AWS account ID from data source if not provided
data "aws_caller_identity" "current" {}

locals {
  cluster_name = "${var.project_name}-${var.environment}"
  aws_account_id = coalesce(var.aws_account_id, data.aws_caller_identity.current.account_id)
  state_bucket = coalesce(var.terraform_state_bucket, "${var.project_name}-terraform-state")
  
  # Use common variables for GitHub URLs
  terraform_modules_url = "github.com/${var.github_org}/${var.terraform_modules_repo}"
  gitops_repo_url = "https://github.com/${var.github_org}/${var.gitops_repo}"
  sample_app_repo_url = "https://github.com/${var.github_org}/${var.sample_app_repo}"
  monitoring_stack_url = "https://github.com/${var.github_org}/${var.monitoring_stack_repo}"
  
  # Common tags - single source of truth
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      ProjectName = var.project_name
      Phase       = "Infrastructure"
    }
  )
}

# =============================================================================
# IAM ROLES & POLICIES
# =============================================================================

module "iam" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/iam?ref=main"
  
  create_eks_cluster_role      = true
  create_eks_node_role         = true
  create_vpc_flow_logs_role    = true
  create_cloudwatch_agent_role = true
  create_eks_access_roles      = var.create_eks_access_roles
  
  name_prefix  = local.cluster_name
  cluster_name = local.cluster_name
  aws_region   = var.aws_region
  
  eks_admin_trusted_principals      = var.eks_admin_principals
  eks_developer_trusted_principals  = var.eks_developer_principals
  eks_viewer_trusted_principals     = var.eks_viewer_principals
  
  tags = local.common_tags
}

# =============================================================================
# VPC & NETWORKING
# =============================================================================

module "vpc" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/vpc?ref=main"
  
  name_prefix            = "${local.cluster_name}-vpc"
  vpc_cidr               = var.vpc_cidr
  azs                    = var.availability_zones
  enable_flow_logs       = var.enable_flow_logs
  vpc_flow_logs_role_arn = module.iam.vpc_flow_logs_role_arn
  
  tags = local.common_tags
  
  depends_on = [module.iam]
}

# =============================================================================
# EKS CLUSTER
# =============================================================================

module "eks" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/eks?ref=main"
  
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  
  # IAM roles
  cluster_iam_role_arn = module.iam.eks_cluster_role_arn
  node_iam_role_arn    = module.iam.eks_node_role_arn
  
  # Network configuration
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  cluster_security_group_id = module.vpc.eks_cluster_sg_id
  nodes_security_group_id   = module.vpc.eks_nodes_sg_id
  
  # Cluster endpoint configuration
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  
  # Node group configuration
  node_group_name        = "default"
  node_group_min_size    = var.node_min_size
  node_group_max_size    = var.node_max_size
  node_group_desired_size = var.node_desired_size
  node_instance_types     = var.node_instance_types
  node_disk_size          = var.node_disk_size
  
  # Cluster access configuration
  cluster_access_principals = var.cluster_access_principals
  cluster_access_config     = var.cluster_access_config
  auto_include_executor     = var.auto_include_executor
  
  # Logging
  create_cluster_log_group = true
  cluster_log_retention_days = var.log_retention_days
  
  tags = local.common_tags
  
  depends_on = [module.vpc, module.iam]
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Security groups are created by VPC module and used by EKS module
# Additional security configuration can be added here if needed

# =============================================================================
# MONITORING
# =============================================================================

module "monitoring" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/monitoring?ref=main"
  
  cluster_name = local.cluster_name
  
  enable_container_insights = var.enable_container_insights
  log_group_retention_days  = var.log_retention_days
  
  cloudwatch_agent_role_arn = module.iam.cloudwatch_agent_role_arn
  
  tags = local.common_tags
  
  depends_on = [module.eks, module.iam]
}

# =============================================================================
# ECR REPOSITORIES
# =============================================================================

module "ecr_backend" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/ecr?ref=main"
  
  repository_name     = "${var.project_name}-${var.environment}-backend"
  image_tag_mutability = "MUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

module "ecr_frontend" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/ecr?ref=main"
  
  repository_name     = "${var.project_name}-${var.environment}-frontend"
  image_tag_mutability = "MUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"
  
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
  
  tags = local.common_tags
}
