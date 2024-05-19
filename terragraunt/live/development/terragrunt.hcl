locals {
  common = yamldecode(file("${get_parent_terragrunt_dir()}/common.yaml"))
  region = get_env("AWS_REGION", get_env("AWS_DEFAULT_REGION", "us-east-1"))
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "main-backend-${local.common.owner}-${local.common.assetid}"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "dynamodb-${local.common.owner}-${local.common.assetid}"
  }
}


# # stage/terragrunt.hcl
# remote_state {
#   backend = "s3"
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
#   config = {
#     bucket = "main-backend-tcc-1119"

#     key = "${path_relative_to_include()}/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "dynamodb-tcc-1119"
#   }
# }
