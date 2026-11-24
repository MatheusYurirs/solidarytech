provider "aws" {
  region = var.aws_region

  # Política de tags FinOps: aplicada automaticamente a todo recurso que aceita tags.
  default_tags {
    tags = local.tags
  }
}
