# Get AWS account ID and region from variables
data "aws_caller_identity" "current" {}

locals {
  aws_account_id = coalesce(var.aws_account_id, data.aws_caller_identity.current.account_id)
  state_bucket   = coalesce(var.terraform_state_bucket, "${var.project_name}-terraform-state")
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    bucket = local.state_bucket
    key    = "${var.project_name}/${var.environment}/infrastructure/terraform.tfstate"
    region = var.aws_region
  }
}

locals {
  rds_address    = try(data.terraform_remote_state.infrastructure.outputs.rds_address, "")
  rds_port       = try(data.terraform_remote_state.infrastructure.outputs.rds_port, "5432")
  rds_db_name    = try(data.terraform_remote_state.infrastructure.outputs.rds_database_name, "taskdb")
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
  # Use password from Secrets Manager only - no fallback to variable
  db_password_from_secret = try(jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).password, "")
  db_user_from_secret     = try(jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[0].secret_string).username, var.db_user)

  # Validate that we have credentials from Secrets Manager
  has_db_credentials = local.rds_secret_arn != "" && local.db_password_from_secret != ""
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
    db-host         = local.rds_address
    db-port         = local.rds_port
    db-name         = local.rds_db_name
    db-pool-min     = var.db_pool_min
    db-pool-max     = var.db_pool_max
    jwt-expires-in  = var.jwt_expires_in
    metrics-enabled = var.metrics_enabled
  }

  depends_on = [module.multi_tenancy]
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
    annotations = {
      "secret-version" = md5("${nonsensitive(local.db_user_from_secret)}:${nonsensitive(local.db_password_from_secret)}")
    }
  }

  type = "Opaque"

  data = {
    db-user     = base64encode(nonsensitive(local.db_user_from_secret))
    db-password = base64encode(nonsensitive(local.db_password_from_secret))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [module.multi_tenancy]
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
    jwt-secret = base64encode("PLACEHOLDER_UPDATE_FROM_SECRETS_MANAGER")
  }

  depends_on = [module.multi_tenancy]
}
