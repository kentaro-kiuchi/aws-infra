output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID."
}

output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "RDS endpoint hostname."
}

output "rds_port" {
  value       = module.rds.port
  description = "RDS PostgreSQL port."
}

output "rds_master_user_secret_arn" {
  value       = module.rds.master_user_secret_arn
  description = "ARN of the RDS-managed master user secret."
}
