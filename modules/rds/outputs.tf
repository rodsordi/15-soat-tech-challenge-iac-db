output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS PostgreSQL endpoint"
}

output "rds_address" {
  value       = aws_db_instance.postgres.address
  description = "RDS PostgreSQL address"
}

output "rds_port" {
  value       = aws_db_instance.postgres.port
  description = "RDS PostgreSQL port"
}

output "secret_arn" {
  value       = aws_secretsmanager_secret.db_secret.arn
  description = "AWS Secrets Manager Secret ARN for DB Credentials"
}
