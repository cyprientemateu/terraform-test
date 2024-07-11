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
  region = local.aws_region
}
provider "random" {

}

locals {
  aws_region = "us-east-1"

  random_s3 = {
    special = false
    upper   = false
    numeric = true
  }

  s3_versioning = "Enabled"

}

module "s3" {
  source = "../../modules/s3"
  #   region        = local.aws_region
  random_s3     = local.random_s3
  s3_versioning = local.s3_versioning

}