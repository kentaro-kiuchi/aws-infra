# Enable this block after the first local-state apply creates the bucket.
#
# terraform {
#   backend "s3" {
#     bucket              = "000000000000-tfstate"
#     key                 = "aws-infra/bootstrap-prod/terraform.tfstate"
#     region              = "ap-northeast-1"
#     use_lockfile        = true
#     encrypt             = true
#     allowed_account_ids = ["000000000000"]
#   }
# }
