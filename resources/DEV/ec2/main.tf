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
#     key            = "teraform-test/ec2/terraform.tfstate"
#     region         = "us-east-1"
#   }
# }

locals {
  aws_region             = "us-east-1"
  ami                    = "ami-0fce2513e5ec9147b"
  instance_type          = "t2.micro"
  key_name               = "terraform"
  vpc_security_group_ids = ["sg-0fa88e0bcf2d36083"]
  # subnet_id                     = "subnet-02e286c9bdfb33f0b"
  enable_termination_protection = false
  volume_size                   = "10"
  allowed_ports = [
    22
  ]
  tags = {
    "id"             = "1119"
    "owner"          = "tcc"
    "teams"          = "Devops"
    "environment"    = "dev"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

module "ec2" {
  source     = "../../../modules/ec2"
  aws_region = local.aws_region
  # ami                    = local.ami
  instance_type          = local.instance_type
  key_name               = local.key_name
  vpc_security_group_ids = local.vpc_security_group_ids
  volume_size            = local.volume_size
  tags                   = local.tags
}