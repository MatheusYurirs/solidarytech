locals {
  tags = {
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
    ManagedBy   = "Terraform"
    DRRole      = "primary"
  }
}

module "platform" {
  source = "../../modules/platform"

  tags        = local.tags
  db_password = var.db_password

  # DR: replica as imagens do ECR para a região do standby.
  ecr_replication_regions = [var.standby_region]
}
