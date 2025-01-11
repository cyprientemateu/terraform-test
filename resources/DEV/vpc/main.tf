terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = local.aws_region
}

# terraform {
#   backend "s3" {
#     bucket         = "main-backend-tcc-1119"
#     dynamodb_table = "dynamodb-tcc-1119"
#     key            = "teraform-test/vpc/terraform.tfstate"
#     region         = "us-east-1"
#   }
# }

locals {
  aws_region           = "us-east-1"
  vpc_cidr             = "10.0.0.0/16"
  nat_number           = "1"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

}

module "vpc" {
  source               = "../../../modules/vpc"
  aws_region           = local.aws_region
  vpc_cidr             = local.vpc_cidr
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  availability_zones   = local.availability_zones

}