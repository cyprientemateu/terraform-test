terraform {
  source = "../../../../modules/DEV//vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  aws_region           = "us-east-1"
  vpc_name             = "tcc-vpc"
  vpc_cidr             = "10.0.0.0/16"
  nat_number           = "1"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

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