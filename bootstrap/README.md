# Bootstrap

## Purpose

This directory manages the AWS resources that must exist before Terraform can be run from GitHub Actions.

Each environment is bootstrapped in its own AWS account. The bootstrap environment stack creates the Terraform state backend and the GitHub Actions OIDC access used by both bootstrap environment Terraform and environment Terraform.

## Resources

The bootstrap environment stack creates the following resources for each environment.

### Terraform State Backend

- S3 bucket for Terraform state
- S3 bucket versioning
- Server-side encryption with SSE-S3
- Bucket owner enforced object ownership
- Public access block
- Bucket policy that denies insecure transport
- Bucket policy that denies cross-account access
- Lifecycle rule for old state versions

### GitHub Actions OIDC

- GitHub Actions OIDC provider
- IAM role for bootstrap environment Terraform: `github-actions-bootstrap-dev`, `github-actions-bootstrap-prod`
- IAM role for environment Terraform: `github-actions-dev`, `github-actions-prod`
- IAM policies for Terraform state access
- IAM policy for the currently managed environment resources

GitHub Environments are named as follows.

- Bootstrap environment Terraform: `bootstrap-dev`, `bootstrap-prod`
- Environment Terraform: `dev`, `prod`

## Apply Procedure

Run the bootstrap environment stack once per environment.

Before running an environment for the first time, update `locals.tf` and `backend.tf` for the target AWS account, state bucket, and backend state key.

For the first apply in an environment, the S3 bucket for the Terraform state backend does not exist yet. Initialize and apply with local state first. For example, for the `dev` environment:

```sh
cd bootstrap/envs/dev
terraform init
terraform plan
terraform apply
```

Whether an environment currently uses local state or the S3 backend is determined by its `backend.tf`. If the S3 backend block is commented out, run the initial apply with local state first, then enable the block and migrate the state.

```sh
terraform init -migrate-state
```

After migration, subsequent `terraform plan` and `terraform apply` runs use the S3 backend.
