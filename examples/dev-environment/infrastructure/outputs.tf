# =============================================================================
# OUTPUTS
# =============================================================================
# Forward outputs from the Terraform-modules infrastructure module
# =============================================================================

# VPC Outputs
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

# EKS Cluster Outputs
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

# IAM Roles
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

# Additional Outputs
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

