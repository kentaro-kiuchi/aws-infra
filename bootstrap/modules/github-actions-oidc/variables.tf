variable "github_actions_bootstrap_env_role_name" {
  type        = string
  description = "IAM role name assumed by GitHub Actions for bootstrap environment Terraform."
}

variable "github_actions_env_role_name" {
  type        = string
  description = "IAM role name assumed by GitHub Actions for environment Terraform."
}

variable "github_bootstrap_env_oidc_subjects" {
  type        = list(string)
  description = "Allowed GitHub OIDC subject claims for assuming the bootstrap environment GitHub Actions role."
}

variable "github_env_oidc_subjects" {
  type        = list(string)
  description = "Allowed GitHub OIDC subject claims for assuming the environment GitHub Actions role."
}

variable "github_oidc_thumbprints" {
  type        = list(string)
  description = "OIDC provider thumbprint placeholders for token.actions.githubusercontent.com. AWS validates GitHub's publicly trusted TLS certificate before falling back to these thumbprints."
  default     = ["ffffffffffffffffffffffffffffffffffffffff"]
}

variable "tfstate_bucket_arn" {
  type        = string
  description = "S3 bucket ARN for Terraform state."
}

variable "bootstrap_env_tfstate_object_keys" {
  type        = list(string)
  description = "S3 object keys for bootstrap environment Terraform state files that the bootstrap environment role may access."
}

variable "env_tfstate_object_keys" {
  type        = list(string)
  description = "S3 object keys for environment Terraform state files that the environment role may access."
}
