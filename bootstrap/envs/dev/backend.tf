# Enable this block after the first local-state apply creates the bucket.
#
# terraform {
#   backend "s3" {
#     bucket              = "129898048085-tfstate"
#     key                 = "aws-infra/bootstrap/terraform.tfstate"
#     region              = "ap-northeast-1"
#     use_lockfile        = true
#     encrypt             = true
#     allowed_account_ids = ["129898048085"]
#   }
# }
