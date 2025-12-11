# =============================================================================
# CONFIGURATION OUTPUTS - Single Source of Truth for All Repos
# =============================================================================
# These outputs make all configuration values available to:
# - GitOps pipeline (via infra_version.yaml)
# - Sample-Saas-App (via Terraform outputs)
# - Monitoring-stack (via Terraform outputs)
# - Any other repository that needs infrastructure configuration
# =============================================================================

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

output "project_config" {
  description = "Complete project configuration - single source of truth"
  value = {
    project_name   = var.project_name
    environment    = var.environment
    aws_account_id = local.aws_account_id
    aws_region     = var.aws_region
    cluster_name   = local.cluster_name
  }
}

# =============================================================================
# SERVICE NAMES & RESOURCE NAMES
# =============================================================================

output "service_names" {
  description = "All service and resource names - single source of truth"
  value = {
    cluster_name           = local.cluster_name
    vpc_name               = "${local.cluster_name}-vpc"
    rds_instance_name      = "${local.cluster_name}-postgres"
    ecr_backend_repo_name  = "${var.project_name}-${var.environment}-backend"
    ecr_frontend_repo_name = "${var.project_name}-${var.environment}-frontend"
    terraform_state_bucket = local.state_bucket
    dynamodb_lock_table    = "${var.project_name}-terraform-state-lock"
  }
}

# =============================================================================
# ECR CONFIGURATION
# =============================================================================

output "ecr_config" {
  description = "ECR repository configuration"
  value = {
    registry_url             = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    backend_repository_url   = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-${var.environment}-backend"
    frontend_repository_url  = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.project_name}-${var.environment}-frontend"
    backend_repository_name  = "${var.project_name}-${var.environment}-backend"
    frontend_repository_name = "${var.project_name}-${var.environment}-frontend"
  }
}

# =============================================================================
# GITHUB REPOSITORY CONFIGURATION
# =============================================================================

output "github_config" {
  description = "GitHub repository URLs - single source of truth"
  value = {
    github_org               = var.github_org
    terraform_modules_url    = local.terraform_modules_url
    gitops_repo_url          = local.gitops_repo_url
    sample_app_repo_url      = local.sample_app_repo_url
    monitoring_stack_url     = local.monitoring_stack_url
    cloudnative_saas_eks_url = "https://github.com/${var.github_org}/cloudnative-saas-eks"
  }
}

# =============================================================================
# TAGS CONFIGURATION
# =============================================================================

output "tags_config" {
  description = "Common tags applied to all resources - single source of truth"
  value = merge(
    var.common_tags,
    {
      Environment = var.environment
      ProjectName = var.project_name
    }
  )
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

output "network_config" {
  description = "Network configuration"
  value = {
    vpc_cidr           = var.vpc_cidr
    availability_zones = var.availability_zones
  }
}

# =============================================================================
# CLUSTER CONFIGURATION
# =============================================================================

output "cluster_config" {
  description = "EKS cluster configuration"
  value = {
    cluster_name    = local.cluster_name
    cluster_version = var.cluster_version
    region          = var.aws_region
    environment     = var.environment
  }
}

# =============================================================================
# COMPLETE CONFIGURATION (All-in-One)
# =============================================================================

output "complete_config" {
  description = "Complete infrastructure configuration - use this for other repos"
  value = {
    project     = var.project_name
    environment = var.environment
    aws = {
      account_id = local.aws_account_id
      region     = var.aws_region
    }
    cluster = {
      name    = local.cluster_name
      version = var.cluster_version
    }
    services = {
      ecr_backend_repo  = "${var.project_name}-${var.environment}-backend"
      ecr_frontend_repo = "${var.project_name}-${var.environment}-frontend"
      rds_instance      = "${local.cluster_name}-postgres"
    }
    github = {
      org               = var.github_org
      terraform_modules = local.terraform_modules_url
      gitops_repo       = local.gitops_repo_url
      sample_app        = local.sample_app_repo_url
      monitoring_stack  = local.monitoring_stack_url
    }
    tags = merge(
      var.common_tags,
      {
        Environment = var.environment
        ProjectName = var.project_name
      }
    )
  }
}

