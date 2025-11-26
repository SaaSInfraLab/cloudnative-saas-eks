# =============================================================================
# RDS POSTGRESQL INSTANCE
# =============================================================================
# Managed PostgreSQL database for multi-tenant SaaS application
# Using RDS instead of in-cluster PostgreSQL to free up cluster resources
# =============================================================================

# DB Subnet Group (for RDS in private subnets)
resource "aws_db_subnet_group" "main" {
  name       = "${local.cluster_name}-db-subnet-group"
  subnet_ids = module.infrastructure.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name}-db-subnet-group"
    }
  )
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name        = "${local.cluster_name}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.infrastructure.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name}-rds-sg"
    }
  )

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.infrastructure.nodes_security_group_id]
    description     = "Allow PostgreSQL access from EKS nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier     = "${local.cluster_name}-postgres"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"  # Free tier eligible (750 hours/month)
  
  allocated_storage     = 20
  max_allocated_storage = 100  # Auto-scaling
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = "taskdb"
  username = "taskuser"
  password = var.db_password  # Set in infrastructure.tfvars
  
  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false  # Private subnet only
  
  # Backup and maintenance
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  skip_final_snapshot    = true  # For dev environment
  
  # Performance
  performance_insights_enabled = false  # Disable for cost savings
  monitoring_interval         = 0     # Disable enhanced monitoring for cost
  
  # Multi-AZ (disabled for cost, enable for production)
  multi_az = false
  
  tags = merge(
    var.tags,
    {
      Name = "${local.cluster_name}-postgres"
    }
  )
}

