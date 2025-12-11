# Secrets Manager IAM Role for IRSA
# Created separately after EKS to avoid circular dependency

module "secrets_manager_iam" {
  source = "github.com/SaaSInfraLab/Terraform-modules//modules/iam?ref=testing"

  create_eks_cluster_role      = false
  create_eks_node_role         = false
  create_vpc_flow_logs_role    = false
  create_cloudwatch_agent_role = false
  create_eks_access_roles      = false
  create_secrets_manager_role  = true

  name_prefix  = local.cluster_name
  cluster_name = local.cluster_name
  aws_region   = var.aws_region

  # Secrets Manager role configuration
  oidc_provider_arn                 = module.eks.oidc_provider_arn
  oidc_provider_url                 = module.eks.oidc_provider_url
  secrets_manager_namespace         = "platform"
  secrets_manager_service_account   = "backend-sa"
  secrets_manager_secret_arns      = [module.rds.rds_secret_arn]
  secrets_manager_kms_key_arns      = [] # Use AWS managed key

  tags = local.common_tags

  depends_on = [module.eks, module.rds]
}

