terraform {
  backend "s3" {
    bucket              = "000000000000-tfstate"
    key                 = "aws-infra/prod/terraform.tfstate"
    region              = "ap-northeast-1"
    use_lockfile        = true
    encrypt             = true
    allowed_account_ids = ["000000000000"]
  }
}
