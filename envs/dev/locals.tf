locals {
  env            = "dev"
  aws_account_id = "129898048085"
  aws_region     = "ap-northeast-1"
  vpc_cidr       = "10.10.0.0/16"
  subnets = {
    public_a = {
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.10.1.0/24"
      tier              = "public"
    }
    public_c = {
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.10.2.0/24"
      tier              = "public"
    }
    public_d = {
      availability_zone = "ap-northeast-1d"
      cidr_block        = "10.10.3.0/24"
      tier              = "public"
    }
    private_a = {
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.10.11.0/24"
      tier              = "private"
    }
    private_c = {
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.10.12.0/24"
      tier              = "private"
    }
    private_d = {
      availability_zone = "ap-northeast-1d"
      cidr_block        = "10.10.13.0/24"
      tier              = "private"
    }
  }
}
