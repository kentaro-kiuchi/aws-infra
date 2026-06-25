output "tfstate_bucket_name" {
  value       = aws_s3_bucket.tf_state.id
  description = "S3 bucket name for Terraform state."
}

output "tfstate_bucket_arn" {
  value       = aws_s3_bucket.tf_state.arn
  description = "S3 bucket ARN for Terraform state."
}
