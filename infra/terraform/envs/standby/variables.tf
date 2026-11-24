variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "donation_db_source_arn" {
  description = "ARN do donation-db primário (output donation_db_arn do env primary)."
  type        = string
  default     = null
}
