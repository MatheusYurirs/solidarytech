variable "project_name" { type = string }

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-donations-dlq"
  message_retention_seconds = 1209600 # 14 dias para investigar mensagens com falha
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "donations" {
  name                       = "${var.project_name}-donations"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30
  sqs_managed_sse_enabled    = true

  # Doação não se perde: após 5 falhas a mensagem vai para a DLQ em vez de sumir.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}

output "queue_url" { value = aws_sqs_queue.donations.url }
output "queue_arn" { value = aws_sqs_queue.donations.arn }
output "dlq_arn" { value = aws_sqs_queue.dlq.arn }
