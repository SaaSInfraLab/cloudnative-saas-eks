# =============================================================================
# TENANT OUTPUTS
# =============================================================================
# All outputs from tenant modules - single source of truth
# =============================================================================

# =============================================================================
# TENANT INFORMATION
# =============================================================================

output "tenant_namespaces" {
  description = "Map of tenant names to their namespace names"
  value       = module.multi_tenancy.tenant_namespaces
}

output "tenant_resource_quotas" {
  description = "Map of tenant names to their resource quota information"
  value       = module.multi_tenancy.tenant_quotas
}

output "tenant_service_accounts" {
  description = "Map of tenant names to their service account information"
  value       = module.multi_tenancy.tenant_service_accounts
}

output "tenant_network_policies" {
  description = "Map of tenant names to their network policy information (if enabled)"
  value       = module.multi_tenancy.tenant_network_policies
}

# =============================================================================
# CLUSTER INFORMATION
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = local.cluster_name
}

output "aws_region" {
  description = "AWS region where tenants are deployed"
  value       = var.aws_region
}

# =============================================================================
# APPLICATION CONFIGURATION
# =============================================================================

output "configmaps_created" {
  description = "ConfigMaps created for each tenant namespace with RDS configuration"
  value = {
    for namespace, cm in kubernetes_config_map.backend_config : namespace => {
      name      = cm.metadata[0].name
      namespace = cm.metadata[0].namespace
      db_host   = cm.data.db-host
      db_port   = cm.data.db-port
      db_name   = cm.data.db-name
    }
  }
}

output "secrets_created" {
  description = "Secrets created for each tenant namespace"
  value = {
    for namespace in keys(kubernetes_secret.postgresql_secret) : namespace => {
      postgresql_secret = kubernetes_secret.postgresql_secret[namespace].metadata[0].name
      backend_secret    = kubernetes_secret.backend_secret[namespace].metadata[0].name
      namespace         = namespace
    }
  }
  sensitive = true
}

# =============================================================================
# MULTI-TENANCY FEATURES
# =============================================================================

output "rbac_enabled" {
  description = "Whether RBAC is enabled"
  value       = module.multi_tenancy.rbac_enabled
}

output "namespace_isolation_enabled" {
  description = "Whether namespace isolation is enabled"
  value       = module.multi_tenancy.namespace_isolation_enabled
}

output "service_accounts_enabled" {
  description = "Whether service accounts for IRSA are enabled"
  value       = module.multi_tenancy.service_accounts_enabled
}
