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
    db-user     = base64encode(var.db_user)
    db-password = base64encode(var.db_password)
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
