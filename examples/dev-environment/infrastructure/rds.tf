module "rds" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/rds?ref=main"

  name_prefix = local.cluster_name
  identifier  = "${local.cluster_name}-postgres"
  
  engine         = "postgres"
  engine_version = "15.7"
  instance_class = "db.t4g.micro"  # Using ARM-based instance for free tier
  
  allocated_storage     = 20  # Free tier allows up to 20GB
  max_allocated_storage = 20  # Fixed size to prevent scaling
  storage_type          = "gp2"
  storage_encrypted     = false
  
  db_name  = "taskdb"
  username = "taskuser"
  password = var.db_password
  
  vpc_id      = module.infrastructure.vpc_id
  subnet_ids  = module.infrastructure.private_subnet_ids
  
  allowed_security_group_ids = [module.infrastructure.nodes_security_group_id]
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
