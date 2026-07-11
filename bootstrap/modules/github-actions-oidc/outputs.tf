output "github_actions_bootstrap_env_role_arn" {
  value       = aws_iam_role.github_actions_bootstrap_env.arn
  description = "IAM role ARN assumed by GitHub Actions for bootstrap environment Terraform."
}

output "github_actions_env_role_arn" {
  value       = aws_iam_role.github_actions_env.arn
  description = "IAM role ARN assumed by GitHub Actions for environment Terraform."
}
