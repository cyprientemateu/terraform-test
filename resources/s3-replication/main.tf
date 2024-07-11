terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "aws" {
  alias  = "main"
  region = local.aws_region_main
}

provider "aws" {
  alias  = "backup"
  region = local.aws_region_backup
}

locals {
  aws_region_main   = "us-east-1"
  aws_region_backup = "us-east-2"
  s3_versioning     = "Enabled"
  force_destroy     = true
}

module "s3" {
  source = "../../modules/s3-replication"
}