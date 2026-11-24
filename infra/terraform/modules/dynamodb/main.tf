variable "table_name" {
  type    = string
  default = "SolidaryTechVolunteers" # nome esperado pelo volunteer-service
}

resource "aws_dynamodb_table" "volunteers" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # FinOps: paga só pelo uso, sem capacidade ociosa
  hash_key     = "volunteer_id"

  attribute {
    name = "volunteer_id"
    type = "S"
  }

  point_in_time_recovery { enabled = true } # DR: restore para qualquer instante dos últimos 35 dias
  server_side_encryption { enabled = true }
}

output "table_name" { value = aws_dynamodb_table.volunteers.name }
output "table_arn" { value = aws_dynamodb_table.volunteers.arn }
