locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "infrastructure" {
  source = "github.com/SaaSInfraLab/Terraform-modules//infrastructure?ref=main"
  
  aws_region  = var.aws_region
  environment = var.environment
  
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  
  cluster_endpoint_config = {
    private_access      = var.cluster_endpoint_private_access
    public_access       = var.cluster_endpoint_public_access
    public_access_cidrs = ["0.0.0.0/0"]
  }
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
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
  
  enable_monitoring  = var.enable_container_insights
  log_retention_days = var.log_retention_days
  enable_flow_logs   = var.enable_flow_logs
  enable_encryption   = true
  
  cluster_access_principals         = var.cluster_access_principals
  cluster_access_config             = var.cluster_access_config
  auto_include_executor             = var.auto_include_executor
  create_eks_access_roles           = var.create_eks_access_roles
  eks_admin_trusted_principals      = var.eks_admin_trusted_principals
  eks_developer_trusted_principals  = var.eks_developer_trusted_principals
  eks_viewer_trusted_principals     = var.eks_viewer_trusted_principals
}
