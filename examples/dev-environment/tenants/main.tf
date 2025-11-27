module "tenants" {
  source = "github.com/SaaSInfraLab/Terraform-modules//tenants?ref=main"
  
  aws_region  = var.aws_region
  environment = var.environment
  tenants     = var.tenants
}
