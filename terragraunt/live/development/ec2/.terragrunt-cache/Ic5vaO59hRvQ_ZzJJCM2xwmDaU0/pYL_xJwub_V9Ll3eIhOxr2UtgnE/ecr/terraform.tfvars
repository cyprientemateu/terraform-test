aws_region = "us-east-1"

tags = {
  "id"             = "1119"
  "owner"          = "tcc"
  "teams"          = "devops"
  "environment"    = "development"
  "project"        = "a1-ecr"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}

backend = {
  bucket         = ""
  dynamodb_table = ""
  key            = ""
  region         = ""
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
