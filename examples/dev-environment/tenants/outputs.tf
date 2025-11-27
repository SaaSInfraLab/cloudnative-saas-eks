output "tenant_namespaces" {
  description = "List of created tenant namespaces"
  value       = module.tenants.tenant_namespaces
}

output "tenant_names" {
  description = "List of tenant names"
  value       = module.tenants.tenant_names
}

output "tenant_summary" {
  description = "Summary of tenant configurations"
  value       = module.tenants.tenant_summary
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.tenants.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.tenants.cluster_endpoint
  sensitive   = true
}

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for this cluster"
  value       = module.tenants.kubeconfig_update_command
}

output "verification_commands" {
  description = "Commands to verify multi-tenant setup"
  value       = module.tenants.verification_commands
}

output "tenant_access_commands" {
  description = "Commands to access each tenant namespace"
  value       = module.tenants.tenant_access_commands
}

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
