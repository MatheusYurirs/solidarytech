variable "project_name" { type = string }
variable "services" { type = list(string) }
variable "registry_id" { type = string }

variable "keep_images" {
  type    = number
  default = 10
}

variable "replication_regions" {
  description = "Regiões para replicar as imagens (DR). Vazio = sem replicação."
  type        = list(string)
  default     = []
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(var.services)
  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration { scan_on_push = true }
}

# FinOps: guarda só as últimas N imagens por repositório.
resource "aws_ecr_lifecycle_policy" "keep_last" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Manter as ultimas ${var.keep_images} imagens"
      selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = var.keep_images }
      action       = { type = "expire" }
    }]
  })
}

# DR: replica as imagens para outra região; o standby sobe sem depender da região principal.
resource "aws_ecr_replication_configuration" "dr" {
  count = length(var.replication_regions) > 0 ? 1 : 0

  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.replication_regions
        content {
          region      = destination.value
          registry_id = var.registry_id
        }
      }
    }
  }
}

output "repository_urls" {
  value = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}
