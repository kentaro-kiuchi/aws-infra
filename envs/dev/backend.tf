terraform {
  backend "s3" {
    bucket              = "129898048085-tfstate"
    key                 = "aws-infra/dev/terraform.tfstate"
    region              = "ap-northeast-1"
    use_lockfile        = true
    encrypt             = true
    allowed_account_ids = ["129898048085"]
  }
}
