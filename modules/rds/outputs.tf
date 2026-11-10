output "endpoint" {
  value       = aws_db_instance.database.address
  description = "RDS endpoint hostname."
}

output "port" {
  value       = aws_db_instance.database.port
  description = "RDS PostgreSQL port."
}

output "master_user_secret_arn" {
  value       = one(aws_db_instance.database.master_user_secret).secret_arn
  description = "ARN of the RDS-managed master user secret."
}
