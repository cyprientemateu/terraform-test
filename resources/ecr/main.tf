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

locals {
  aws_region = "us-east-1"

  tags = {
    "id"             = "1119"
    "owner"          = "TCC"
    "teams"          = "devops"
    "environment"    = "development"
    "project"        = "a1-ecr"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
  scan_config = {
    "scan_type"      = "BASIC"
    "scan_frequency" = "SCAN_ON_PUSH"
    "filter"         = "*"
  }
  mutability = "MUTABLE"

  scan_on_push = true

  ecr_repo_name = [
    "ui",
    "db",
    "redis",
    "auth",
    "weather"
  ]


  backend = {
    bucket         = ""
    dynamodb_table = ""
    key            = ""
    region         = ""
  }
}

module "ec2" {
  source = "../../modules/DEV/ecr"
  #   source        = "git@github.com:cyprientemateu/terraform-test/tree/main/modules/DEV/"
  aws_region    = local.aws_region
  tags          = local.tags
  backend       = local.backend
  ecr_repo_name = local.ecr_repo_name
  mutability    = local.mutability
  scan_on_push  = local.scan_on_push
}