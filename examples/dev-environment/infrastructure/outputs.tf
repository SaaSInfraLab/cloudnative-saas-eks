output "vpc_id" {
  description = "ID of the VPC"
  value       = module.infrastructure.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.infrastructure.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.infrastructure.public_subnet_ids
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.infrastructure.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.infrastructure.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Version of the EKS cluster"
  value       = module.infrastructure.cluster_version
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.infrastructure.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.infrastructure.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.infrastructure.cluster_security_group_id
}

output "nodes_security_group_id" {
  description = "Security group ID attached to the EKS worker nodes"
  value       = module.infrastructure.nodes_security_group_id
}

# RDS Outputs
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
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.infrastructure.cluster_iam_role_arn
}

output "node_iam_role_arn" {
  description = "IAM role ARN of the EKS worker nodes"
  value       = module.infrastructure.node_iam_role_arn
}

output "eks_admin_role_arn" {
  description = "ARN of the EKS Admin IAM role"
  value       = module.infrastructure.eks_admin_role_arn
}

output "eks_developer_role_arn" {
  description = "ARN of the EKS Developer IAM role"
  value       = module.infrastructure.eks_developer_role_arn
}

output "eks_viewer_role_arn" {
  description = "ARN of the EKS Viewer IAM role"
  value       = module.infrastructure.eks_viewer_role_arn
}

output "aws_region" {
  description = "AWS region where infrastructure is deployed"
  value       = module.infrastructure.aws_region
}

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for this cluster"
  value       = module.infrastructure.kubeconfig_update_command
}

output "cluster_info" {
  description = "Quick reference information about the cluster"
  value = {
    cluster_name    = module.infrastructure.cluster_name
    cluster_version = module.infrastructure.cluster_version
    region          = module.infrastructure.aws_region
    environment     = var.environment
  }
}

output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.infrastructure.ecr_backend_repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = module.infrastructure.ecr_frontend_repository_url
}

output "ecr_backend_repository_name" {
  description = "Name of the backend ECR repository"
  value       = module.infrastructure.ecr_backend_repository_name
}

output "ecr_frontend_repository_name" {
  description = "Name of the frontend ECR repository"
  value       = module.infrastructure.ecr_frontend_repository_name
}

output "ecr_registry_id" {
  description = "The registry ID where ECR repositories were created"
  value       = module.infrastructure.ecr_registry_id
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = try(aws_db_instance.postgres.endpoint, null)
}

output "rds_address" {
  description = "RDS PostgreSQL address (hostname only)"
  value       = try(aws_db_instance.postgres.address, null)
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = try(aws_db_instance.postgres.port, null)
}

output "rds_database_name" {
  description = "RDS PostgreSQL database name"
  value       = try(aws_db_instance.postgres.db_name, null)
}
