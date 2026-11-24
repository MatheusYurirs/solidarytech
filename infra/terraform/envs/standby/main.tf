# Warm Standby (DR opção B): mesmo módulo, outra região, capacidade mínima.
# Subir com 1 comando: scripts/dr-standby-up.sh
locals {
  tags = {
    Project     = "SolidaryTech"
    Environment = "Production"
    CostCenter  = "NGO-Core"
    ManagedBy   = "Terraform"
    DRRole      = "standby"
  }
}

module "platform" {
  source = "../../modules/platform"

  tags        = local.tags
  db_password = var.db_password
  vpc_cidr    = "10.1.0.0/16" # diferente do primário (permite peering no futuro)

  # Capacidade mínima enquanto está "morno"; escala no failover.
  node_min     = 1
  node_desired = 1
  node_max     = 4

  # Réplica cross-region do banco de doações (dado crítico). null = banco vazio (sem origem).
  donation_db_source_arn = var.donation_db_source_arn

  # Imagens chegam por replicação do ECR primário.
  create_ecr = false
}
