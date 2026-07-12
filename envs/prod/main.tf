module "vpc" {
  source = "../../modules/vpc"

  env      = local.env
  vpc_cidr = local.vpc_cidr
}
