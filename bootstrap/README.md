# Bootstrap

## Purpose

This directory manages the AWS resources that must exist before Terraform can be run from GitHub Actions.

Each environment is bootstrapped in its own AWS account. The bootstrap stack creates the Terraform state backend and the GitHub Actions OIDC access used by both bootstrap Terraform and environment Terraform.

## Resources

The bootstrap stack creates the following resources for each environment.

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
- IAM role for bootstrap Terraform: `github-actions-bootstrap`
- IAM role for environment Terraform: `github-actions-terraform`
- IAM policies for Terraform state access
- IAM policy for the currently managed environment resources

## Apply Procedure

Run the bootstrap stack once per environment.

For the first apply in an environment, the S3 bucket for the Terraform state backend does not exist yet. Initialize and apply with local state first.

```sh
cd bootstrap/envs/dev
terraform init
terraform plan
terraform apply
```

```sh
cd bootstrap/envs/prod
terraform init
terraform plan
terraform apply
```

After the apply succeeds, enable the S3 backend in `backend.tf` and migrate the state.

```sh
terraform init -migrate-state
```

After migration, subsequent `terraform plan` and `terraform apply` runs use the S3 backend.
