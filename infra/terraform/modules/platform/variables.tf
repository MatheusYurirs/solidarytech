variable "project_name" {
  type    = string
  default = "solidarytech"
}

# Política FinOps (PDF Fase 5, p.4): o código recusa tags obrigatórias ausentes ou com valor errado.
variable "tags" {
  description = "Tags FinOps. Project, Environment e CostCenter são obrigatórias."
  type        = map(string)

  validation {
    condition     = alltrue([for k in ["Project", "Environment", "CostCenter"] : contains(keys(var.tags), k)])
    error_message = "Tags obrigatórias ausentes: Project, Environment e CostCenter."
  }
  validation {
    condition = (
      try(var.tags["Project"], "") == "SolidaryTech" &&
      try(var.tags["Environment"], "") == "Production" &&
      try(var.tags["CostCenter"], "") == "NGO-Core"
    )
    error_message = "Valores exigidos: Project=SolidaryTech, Environment=Production, CostCenter=NGO-Core."
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min" {
  type    = number
  default = 2
}

variable "node_desired" {
  type    = number
  default = 3
}

variable "node_max" {
  type    = number
  default = 5
}

variable "donation_multi_az" {
  description = "Multi-AZ no banco de doações (recomendado em produção real; dobra o custo da instância)."
  type        = bool
  default     = false
}

variable "donation_db_source_arn" {
  description = "Standby: ARN do donation-db da região primária para criar réplica cross-region."
  type        = string
  default     = null
}

variable "create_ecr" {
  description = "false no standby: os repositórios chegam por replicação do ECR primário."
  type        = bool
  default     = true
}

variable "ecr_replication_regions" {
  type    = list(string)
  default = []
}
