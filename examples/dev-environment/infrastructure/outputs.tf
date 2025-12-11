# =============================================================================
# INFRASTRUCTURE OUTPUTS
# =============================================================================
# All outputs from infrastructure modules - single source of truth
# =============================================================================

# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

# =============================================================================
# EKS CLUSTER OUTPUTS
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "nodes_security_group_id" {
  description = "Security group ID attached to the EKS worker nodes"
  value       = module.vpc.eks_nodes_sg_id
}

# =============================================================================
# IAM ROLE OUTPUTS
# =============================================================================

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.iam.eks_cluster_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS worker nodes"
  value       = module.iam.eks_node_role_arn
}

output "eks_admin_role_arn" {
  description = "ARN of the EKS Admin IAM role"
  value       = module.iam.eks_admin_role_arn
}

output "eks_developer_role_arn" {
  description = "ARN of the EKS Developer IAM role"
  value       = module.iam.eks_developer_role_arn
}

output "eks_viewer_role_arn" {
  description = "ARN of the EKS Viewer IAM role"
  value       = module.iam.eks_viewer_role_arn
}

output "secrets_manager_role_arn" {
  description = "ARN of the Secrets Manager IAM role for IRSA"
  value       = module.iam.secrets_manager_role_arn
}

output "secrets_manager_role_name" {
  description = "Name of the Secrets Manager IAM role for IRSA"
  value       = module.iam.secrets_manager_role_name
}

# =============================================================================
# AWS CONFIGURATION OUTPUTS
# =============================================================================

output "aws_region" {
  description = "AWS region where infrastructure is deployed"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS Account ID where resources are deployed"
  value       = local.aws_account_id
}

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "cluster_info" {
  description = "Quick reference information about the cluster"
  value = {
    cluster_name    = module.eks.cluster_name
    cluster_version = module.eks.cluster_version
    region          = var.aws_region
    environment     = var.environment
  }
}

# =============================================================================
# ECR REPOSITORY OUTPUTS
# =============================================================================

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.ecr_backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.ecr_frontend.repository_url
}

output "ecr_backend_repository_name" {
  description = "Name of the backend ECR repository"
  value       = module.ecr_backend.repository_name
}

output "ecr_frontend_repository_name" {
  description = "Name of the frontend ECR repository"
  value       = module.ecr_frontend.repository_name
}

output "ecr_registry_id" {
  description = "The registry ID where ECR repositories were created"
  value       = module.ecr_backend.registry_id
}

output "ecr_registry_url" {
  description = "ECR registry URL (without repository name)"
  value       = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

# =============================================================================
# RDS OUTPUTS
# =============================================================================

output "rds_instance_id" {
  description = "The RDS instance ID"
  value       = module.rds.db_instance_id
}

output "rds_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_instance_username" {
  description = "The master username for the database"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "rds_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}

output "rds_security_group_id" {
  description = "The security group ID of the RDS instance"
  value       = module.rds.security_group_id
}

output "rds_secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager"
  value       = module.rds.rds_secret_arn
}

output "rds_secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  value       = module.rds.rds_secret_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "RDS PostgreSQL address (hostname only)"
  value       = module.rds.db_instance_address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "RDS PostgreSQL database name"
  value       = module.rds.db_instance_name
}
