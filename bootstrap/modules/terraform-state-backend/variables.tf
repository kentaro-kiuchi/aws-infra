variable "tfstate_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform state."
}

variable "aws_account_id" {
  type        = string
  description = "AWS account ID that owns the Terraform state bucket."
}

variable "tfstate_noncurrent_version_retention_days" {
  type        = number
  description = "Number of days to retain noncurrent Terraform state object versions."
  default     = 90
}
