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
#     key            = "teraform-test/eks1/terraform.tfstate"
#     region         = "us-east-1"
#   }
# }

locals {
  aws_region              = "us-east-1"
  eks_version             = "1.28"
  endpoint_private_access = false
  endpoint_public_access  = true


  node_min     = "1"
  desired_node = "1"
  node_max     = "3"

  ec2_ssh_key = "terraform"
  #   deployment_nodegroup      = "blue_green"
  capacity_type             = "ON_DEMAND"
  ami_type                  = "AL2_x86_64"
  instance_types            = "t2.medium"
  disk_size                 = "10"
  shared_owned              = "shared"
  enable_cluster_autoscaler = "true"
  cluster_name              = "tcc-eks-cluster-1119-a1"

  tags = {
    "id"             = "1119"
    "owner"          = "tcc"
    "environment"    = "dev"
    "teams"          = "Devops"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

module "eks1" {
  source                    = "../../../modules/eks1"
  aws_region                = local.aws_region
  eks_version               = local.eks_version
  endpoint_private_access   = local.endpoint_private_access
  endpoint_public_access    = local.endpoint_public_access
  tags                      = local.tags
  enable_cluster_autoscaler = local.enable_cluster_autoscaler
  shared_owned              = local.shared_owned
}