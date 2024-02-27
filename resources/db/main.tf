terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source = "../../modules/DEV/vpc"
  # aws_region           = local.aws_region
  # vpc_name             = local.vpc_name
  # vpc_cidr             = local.vpc_cidr
  # public_subnet_cidrs  = local.public_subnet_cidrs
  # private_subnet_cidrs = local.private_subnet_cidrs
  # availability_zones   = local.availability_zones

}

# module "db" {
#   source = "../../modules/DEV/db"
#   vpc_id = aws_vpc.tcc_vpc
# }
