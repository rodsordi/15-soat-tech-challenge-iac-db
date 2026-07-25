output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS PostgreSQL endpoint"
}

output "rds_address" {
  value       = module.rds.rds_address
  description = "RDS PostgreSQL address"
}

output "secret_arn" {
  value       = module.rds.secret_arn
  description = "AWS Secrets Manager Secret ARN for DB Credentials"
}
