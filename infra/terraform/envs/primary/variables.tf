variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "standby_region" {
  type    = string
  default = "us-west-2"
}

variable "db_password" {
  description = "Senha dos bancos. Vem de TF_VAR_db_password (gerada pelos scripts)."
  type        = string
  sensitive   = true
}
