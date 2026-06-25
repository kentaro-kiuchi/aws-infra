output "github_actions_bootstrap_role_arn" {
  value       = aws_iam_role.github_actions_bootstrap.arn
  description = "IAM role ARN assumed by GitHub Actions for bootstrap Terraform."
}

output "github_actions_env_role_arn" {
  value       = aws_iam_role.github_actions_env.arn
  description = "IAM role ARN assumed by GitHub Actions for environment Terraform."
}
