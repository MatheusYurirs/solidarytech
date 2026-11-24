variable "project_name" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "tags" { type = map(string) }

variable "kubernetes_version" {
  description = "Usar versão em standard support: versões antigas cobram 'extended support' (FinOps)."
  type        = string
  default     = "1.33"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "min_nodes" {
  type    = number
  default = 2
}

variable "desired_nodes" {
  type    = number
  default = 3
}

variable "max_nodes" {
  type    = number
  default = 5
}
