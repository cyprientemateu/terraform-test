aws_region = "us-east-1"

cluster_name = "tcc-eks-cluster-1119-a1"

eks_version = 1.29

endpoint_public_access = true

endpoint_private_access = false

endpoint_public_access_cidrs = ["0.0.0.0/0"]

tags = {
  "id"             = "1119"
  "owner"          = "tcc"
  "teams"          = "Devops"
  "environment"    = "dev"
  "project"        = "a1"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}

shared_owned              = "shared"
enable_cluster_autoscaler = "true"

# public_subnet_ids = [
#   "data.aws_subnet.public-01.id",
#   "data.aws_subnet.public-02.id",
#   data.aws_subnet.public-03.id
# ]

# private_subnet_ids = [
#   "aws_subnet.private_1.id",
#   "aws_subnet.private_2.id",
#   data.aws_subnet.private-03.id
# ]