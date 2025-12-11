module "rds" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/rds?ref=testing"

  name_prefix = local.cluster_name
  identifier  = "${local.cluster_name}-postgres"

  engine         = "postgres"
  engine_version = "15.10"
  instance_class = "db.t4g.micro"

  allocated_storage          = 50
  max_allocated_storage      = 100
  auto_minor_version_upgrade = true
  storage_type               = "gp2"
  storage_encrypted          = false

  db_name  = "taskdb"
  username = "taskuser"
  # Password is automatically managed by AWS Secrets Manager
  # No password variable needed - retrieve from Secrets Manager using secret_arn output

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_security_group_ids = [
    module.vpc.eks_nodes_sg_id,
    module.eks.cluster_security_group_id
  ]
  publicly_accessible = false

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  skip_final_snapshot     = true

  performance_insights_enabled = false
  monitoring_interval          = 0
  multi_az                     = false

  apply_immediately   = true
  deletion_protection = false

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
    var.common_tags,
    {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}
