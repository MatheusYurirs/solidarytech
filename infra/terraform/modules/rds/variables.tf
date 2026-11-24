variable "identifier" { type = string }
variable "db_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_group_name" { type = string }
variable "allowed_security_group_ids" { type = list(string) }

variable "password" {
  type      = string
  sensitive = true
  default   = null
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  type    = number
  default = 1
}

variable "replicate_source_db" {
  description = "ARN do banco de origem (réplica cross-region para DR). null = banco normal."
  type        = string
  default     = null
}
