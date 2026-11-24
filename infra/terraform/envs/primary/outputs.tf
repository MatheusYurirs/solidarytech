output "eks_cluster_name" { value = module.platform.eks_cluster_name }
output "ngo_db_endpoint" { value = module.platform.ngo_db_endpoint }
output "donation_db_endpoint" { value = module.platform.donation_db_endpoint }
# Usado pelo standby para criar a réplica cross-region.
output "donation_db_arn" { value = module.platform.donation_db_arn }
output "dynamodb_table" { value = module.platform.dynamodb_table }
output "sqs_url" { value = module.platform.sqs_url }
output "ecr_urls" { value = module.platform.ecr_urls }
