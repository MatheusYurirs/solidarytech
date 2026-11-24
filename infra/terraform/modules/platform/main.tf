# Composição completa da plataforma SolidaryTech.
# O MESMO módulo sobe a região primária e o standby (DR opção B): só mudam as variáveis.

data "aws_caller_identity" "current" {}

module "network" {
  source       = "../network"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "eks" {
  source             = "../eks"
  project_name       = var.project_name
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  tags               = var.tags
  kubernetes_version = var.kubernetes_version
  instance_types     = var.node_instance_types
  min_nodes          = var.node_min
  desired_nodes      = var.node_desired
  max_nodes          = var.node_max
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = module.network.private_subnet_ids
}

# Banco de ONGs: importante, mas fora do hot path.
module "ngo_db" {
  source                     = "../rds"
  identifier                 = "${var.project_name}-ngo-db"
  db_name                    = "ngo_db"
  password                   = var.db_password
  vpc_id                     = module.network.vpc_id
  subnet_group_name          = aws_db_subnet_group.main.name
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
}

# Banco de doações: HOT PATH. Backup de 7 dias; no standby vira réplica cross-region (RPO ~ segundos).
module "donation_db" {
  source                     = "../rds"
  identifier                 = "${var.project_name}-donation-db"
  db_name                    = "donation_db"
  password                   = var.db_password
  vpc_id                     = module.network.vpc_id
  subnet_group_name          = aws_db_subnet_group.main.name
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  multi_az                   = var.donation_multi_az
  backup_retention_days      = 7
  replicate_source_db        = var.donation_db_source_arn
}

module "dynamodb" {
  source = "../dynamodb"
}

module "sqs" {
  source       = "../sqs"
  project_name = var.project_name
}

module "ecr" {
  count               = var.create_ecr ? 1 : 0
  source              = "../ecr"
  project_name        = var.project_name
  services            = ["ngo-service", "donation-service", "volunteer-service"]
  registry_id         = data.aws_caller_identity.current.account_id
  replication_regions = var.ecr_replication_regions
}
