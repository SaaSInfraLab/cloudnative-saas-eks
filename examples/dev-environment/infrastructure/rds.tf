# Data source to get the actual EKS cluster security group
# This ensures we use the real cluster security group created by AWS, not the one from Terraform state
data "aws_eks_cluster" "main" {
  name = local.cluster_name
}

module "rds" {
  source = "../../../../Terraform-modules/modules/rds"

  name_prefix = local.cluster_name
  identifier  = "${local.cluster_name}-postgres"
  
  engine         = "postgres"
  engine_version = "15.10" 
  instance_class = "db.t4g.micro" 
  
  allocated_storage     = 50 
  max_allocated_storage = 100 
  auto_minor_version_upgrade = true  
  storage_type          = "gp2"
  storage_encrypted     = false
  
  db_name  = "taskdb"
  username = "taskuser"
  password = var.db_password
  
  vpc_id      = module.infrastructure.vpc_id
  subnet_ids  = module.infrastructure.private_subnet_ids
  
  # Allow access from both EKS nodes and cluster security groups
  # Note: EKS nodes use the cluster security group for pod networking
  # We use data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id to get the actual
  # cluster security group created by AWS, which may differ from Terraform state
  allowed_security_group_ids = [
    module.infrastructure.nodes_security_group_id,
    module.infrastructure.cluster_security_group_id,
    data.aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  ]
  publicly_accessible       = false
  
  # Minimal backup settings
  backup_retention_period = 1  # Keep only 1 day of backups
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  skip_final_snapshot    = true
  
  # Disable costly features
  performance_insights_enabled = false
  monitoring_interval         = 0
  multi_az                    = false
  
  # Apply changes immediately (for testing/debugging)
  apply_immediately = true
  
  # Enable deletion protection in production
  deletion_protection = false
  
  # Database parameters
  db_parameters = [
    {
      name  = "log_statement"
      value = "none"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"
    }
  ]
  
  tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
