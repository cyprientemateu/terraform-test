aws_region = "us-east-1"

eks_name = "eks-cluster"

tags = {
  "id"             = "1119"
  "owner"          = "TCC"
  "teams"          = "Devops"
  "environment"    = "development"
  "project"        = "a1"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}

public_subnet_ids = [
  "aws_subnet.public_1.id",
  "aws_subnet.public_2.id"
]

private_subnet_ids = [
  "aws_subnet.private_1.id",
  "aws_subnet.private_2.id"
]