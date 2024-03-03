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

# terraform {
#   backend "s3" {
#     bucket         = "cyprienbucket"
#     dynamodb_table = "terraform-lock"
#     key            = "tcc/aurora-PostgreSQL-db/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#   }
# }

locals {
  aws_region = "us-east-1"

  vpc_id                  = "vpc-026a1034816688c1d"
  subnet_ids              = ["subnet-02e286c9bdfb33f0b", "subnet-011cf4a50c2518de6"]
  avalability_zones       = ["us-east-1a", "us-east-1b"]
  instance_count          = 2
  instance_class          = "db.r5.large"
  engine_version          = "11.9"
  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
}

module "db" {
  source                  = "../../modules/DEV/db"
  aws_region              = local.aws_region
  vpc_id                  = local.vpc_id
  subnet_ids              = local.subnet_ids
  avalability_zones       = local.avalability_zones
  instance_count          = local.instance_count
  instance_class          = local.instance_class
  engine_version          = local.engine_version
  backup_retention_period = local.backup_retention_period
  preferred_backup_window = local.preferred_backup_window
}
