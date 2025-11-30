data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  
  config = {
    bucket = "saas-infra-lab-terraform-state"
    key    = "saas-infra-lab/dev/infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  rds_address = try(data.terraform_remote_state.infrastructure.outputs.rds_address, "")
  rds_port    = try(data.terraform_remote_state.infrastructure.outputs.rds_port, "5432")
  rds_db_name = try(data.terraform_remote_state.infrastructure.outputs.rds_database_name, "taskdb")
  rds_secret_arn = try(data.terraform_remote_state.infrastructure.outputs.rds_secret_arn, "")
}

# Read RDS credentials from AWS Secrets Manager for consistency
data "aws_secretsmanager_secret" "rds_credentials" {
  count = local.rds_secret_arn != "" ? 1 : 0
  arn   = local.rds_secret_arn
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  count     = local.rds_secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.rds_credentials[0].id
}

locals {
  # Use password from Secrets Manager if available, otherwise fall back to variable
  db_password_from_secret = try(jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).password, var.db_password)
  db_user_from_secret     = try(jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).username, var.db_user)
}

data "aws_eks_cluster" "current" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.current.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.current.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.current.name, "--region", var.aws_region]
  }
}

resource "kubernetes_config_map" "backend_config" {
  for_each = { for tenant in var.tenants : tenant.namespace => tenant }

  metadata {
    name      = "backend-config"
    namespace = each.value.namespace
    labels = {
      app     = "backend"
      tenant  = each.value.name
      managed = "terraform"
    }
  }

  data = {
    db-host        = local.rds_address
    db-port        = local.rds_port
    db-name        = local.rds_db_name
    db-pool-min    = var.db_pool_min
    db-pool-max    = var.db_pool_max
    jwt-expires-in = var.jwt_expires_in
    metrics-enabled = var.metrics_enabled
  }

  depends_on = [module.tenants]
}

resource "kubernetes_secret" "postgresql_secret" {
  for_each = { for tenant in var.tenants : tenant.namespace => tenant }

  metadata {
    name      = "postgresql-secret"
    namespace = each.value.namespace
    labels = {
      app     = "backend"
      tenant  = each.value.name
      managed = "terraform"
    }
  }

  type = "Opaque"

  data = {
    db-user     = base64encode(local.db_user_from_secret)
    db-password = base64encode(local.db_password_from_secret)
  }

  depends_on = [module.tenants]
}

resource "kubernetes_secret" "backend_secret" {
  for_each = { for tenant in var.tenants : tenant.namespace => tenant }

  metadata {
    name      = "backend-secret"
    namespace = each.value.namespace
    labels = {
      app     = "backend"
      tenant  = each.value.name
      managed = "terraform"
    }
  }

  type = "Opaque"

  data = {
    jwt-secret = base64encode(var.jwt_secret)
  }

  depends_on = [module.tenants]
}
