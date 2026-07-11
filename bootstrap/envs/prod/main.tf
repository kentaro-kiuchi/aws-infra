module "terraform_state_backend" {
  source = "../../modules/terraform-state-backend"

  tfstate_bucket_name = "${local.aws_account_id}-tfstate"
  aws_account_id      = local.aws_account_id
}

module "github_actions_oidc" {
  source = "../../modules/github-actions-oidc"

  tfstate_bucket_arn                     = module.terraform_state_backend.tfstate_bucket_arn
  bootstrap_env_tfstate_object_keys      = ["aws-infra/bootstrap-${local.env}/terraform.tfstate"]
  env_tfstate_object_keys                = ["aws-infra/${local.env}/terraform.tfstate"]
  github_actions_bootstrap_env_role_name = "github-actions-bootstrap-${local.env}"
  github_actions_env_role_name           = "github-actions-${local.env}"
  github_bootstrap_env_oidc_subjects = [
    "repo:kentaro-kiuchi/aws-infra:environment:bootstrap-${local.env}",
  ]
  github_env_oidc_subjects = [
    "repo:kentaro-kiuchi/aws-infra:environment:${local.env}",
  ]
}
