# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

# EKS Cluster Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster API server"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = module.eks.cluster_version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

# Node Group Outputs
output "node_group_id" {
  description = "ID of the on-demand node group"
  value       = module.eks_node_group.node_group_id
}

output "node_group_status" {
  description = "Status of the on-demand node group"
  value       = module.eks_node_group.node_group_status
}

output "spot_node_group_id" {
  description = "ID of the spot node group (if enabled)"
  value       = var.enable_spot_instances ? module.eks_spot_node_group[0].node_group_id : null
}

# Configuration Commands
output "configure_kubectl" {
  description = "Command to configure kubectl"
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

# Monitoring URLs (when enabled)
output "grafana_info" {
  description = "Grafana access information (if enabled)"
  value = var.enable_grafana ? {
    message = "Grafana is deployed. Use 'kubectl port-forward -n monitoring svc/grafana 3000:80' to access locally"
    url     = "http://localhost:3000"
  } : null
}

output "prometheus_info" {
  description = "Prometheus access information (if enabled)"
  value = var.enable_prometheus ? {
    message = "Prometheus is deployed. Use 'kubectl port-forward -n monitoring svc/prometheus-server 9090:80' to access locally"
    url     = "http://localhost:9090"
  } : null
}