output "tfstate_bucket_name" {
  value       = module.terraform_state_backend.tfstate_bucket_name
  description = "S3 bucket name for Terraform state."
}

output "github_actions_bootstrap_env_role_arn" {
  value       = module.github_actions_oidc.github_actions_bootstrap_env_role_arn
  description = "IAM role ARN assumed by GitHub Actions for bootstrap environment Terraform."
}

output "github_actions_env_role_arn" {
  value       = module.github_actions_oidc.github_actions_env_role_arn
  description = "IAM role ARN assumed by GitHub Actions for environment Terraform."
}
