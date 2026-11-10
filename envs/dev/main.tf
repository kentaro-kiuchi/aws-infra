module "vpc" {
  source = "../../modules/vpc"

  env      = local.env
  vpc_cidr = local.vpc_cidr
  subnets  = local.subnets
}

module "rds" {
  source = "../../modules/rds"

  env                    = local.env
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  availability_zone      = "ap-northeast-1a"
  allowed_client_cidr    = "10.10.11.0/24"
  engine_version         = "18.6"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 5
  storage_type           = "gp2"
  master_username        = "rds_admin"
  manage_master_password = true
}
