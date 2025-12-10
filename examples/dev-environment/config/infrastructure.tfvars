# =============================================================================
# INFRASTRUCTURE CONFIGURATION - Dev Environment
# =============================================================================
# This file contains infrastructure-specific configuration values.
# Common values are in common.tfvars
#
# Usage:
#   terraform apply -var-file="common.tfvars" -var-file="infrastructure.tfvars"
# =============================================================================

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# =============================================================================
# EKS CLUSTER CONFIGURATION
# =============================================================================
cluster_version                 = "1.32"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true

# =============================================================================
# NODE GROUP CONFIGURATION
# =============================================================================
# m7i-flex.large: Free tier eligible, 1 vCPU, 8GB RAM, ~29 pods/node (BEST for EKS!)
node_instance_types = ["m7i-flex.large"]
node_desired_size   = 2  # 2 nodes with m7i-flex.large (free tier eligible, much better capacity)
node_min_size       = 1
node_max_size       = 2  # 2 nodes should provide plenty of capacity
node_disk_size      = 20

# =============================================================================
# SPOT INSTANCES CONFIGURATION
# =============================================================================
enable_spot_instances = false
spot_instance_types   = ["t3.micro", "t3a.micro"]
spot_desired_size     = 0
spot_min_size         = 0
spot_max_size         = 2

# =============================================================================
# MONITORING CONFIGURATION
# =============================================================================
enable_container_insights = false
enable_flow_logs         = false
log_retention_days       = 7

# =============================================================================
# EKS ACCESS CONFIGURATION
# =============================================================================
create_eks_access_roles = true

# IAM Principals - Replace with your actual IAM user/role ARNs
# Format: "arn:aws:iam::ACCOUNT_ID:user/USERNAME" or "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
# The AWS account ID will be automatically detected, but you can construct ARNs like:
# "arn:aws:iam::${aws_account_id}:user/Akilesh_user"
# Or use the actual account ID if known:
eks_admin_principals = [
  # Example: "arn:aws:iam::123456789012:user/Akilesh_user"
  # Add your IAM user ARNs here
]

eks_developer_principals = [
  # Example: "arn:aws:iam::123456789012:user/Akilesh_user"
  # Add your IAM user ARNs here
]

eks_viewer_principals = [
  # Example: "arn:aws:iam::123456789012:user/Akilesh_user"
  # Add your IAM user ARNs here
]

cluster_access_principals = [
  "arn:aws:iam::240623017727:user/CLI"
  # Add additional IAM principal ARNs here as needed
]

cluster_access_config = {
  "arn:aws:iam::240623017727:user/CLI" = {
    policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope = {
      type       = "cluster"
      namespaces = []
    }
  }
  # Add additional configurations as needed
}

auto_include_executor = true

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================
# WARNING: Do NOT put database passwords in this file!
# Database passwords should be stored in AWS Secrets Manager only.
# The Terraform code will read the password from Secrets Manager automatically.
# db_password is removed - use AWS Secrets Manager instead

