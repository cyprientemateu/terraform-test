aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
cidr_block         = "10.0.0.0/16"
control_plane_name = "dev-test1"
nat_number         = 1
tags = {
  "id"             = "1119"
  "owner"          = "TCC"
  "teams"          = "Devops"
  "environment"    = "dev"
  "project"        = "test1"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}