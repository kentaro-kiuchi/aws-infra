terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region              = local.aws_region
  allowed_account_ids = [local.aws_account_id]

  default_tags {
    tags = {
      Project = "aws-infra"
      Env     = local.env
      Managed = "terraform"
      Layer   = local.env
    }
  }
}
