terraform {
  source = "../../../../modules/DEV//eks1"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "${get_terragrunt_dir()}/../vpc", 
    ]
}

inputs = {
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