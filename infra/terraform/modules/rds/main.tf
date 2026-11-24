locals {
  is_replica = var.replicate_source_db != null
}

resource "aws_security_group" "db" {
  name        = "${var.identifier}-sg"
  description = "PostgreSQL ${var.identifier}: acesso apenas dos pods EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "Pods EKS"
  }

  tags = { Name = "${var.identifier}-sg" }
}

resource "aws_db_instance" "this" {
  identifier        = var.identifier
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  # Réplica herda banco/usuário da origem: esses campos não podem ser enviados.
  db_name  = local.is_replica ? null : var.db_name
  username = local.is_replica ? null : "postgres"
  password = local.is_replica ? null : var.password

  replicate_source_db     = var.replicate_source_db
  db_subnet_group_name    = var.subnet_group_name
  vpc_security_group_ids  = [aws_security_group.db.id]
  multi_az                = var.multi_az
  publicly_accessible     = false
  backup_retention_period = var.backup_retention_days
  skip_final_snapshot     = true # Academy: facilita o destroy
  deletion_protection     = false

  tags = { Name = var.identifier }
}
