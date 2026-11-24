output "eks_cluster_name" { value = module.platform.eks_cluster_name }
output "ngo_db_endpoint" { value = module.platform.ngo_db_endpoint }
output "donation_db_endpoint" { value = module.platform.donation_db_endpoint }
output "dynamodb_table" { value = module.platform.dynamodb_table }
output "sqs_url" { value = module.platform.sqs_url }
