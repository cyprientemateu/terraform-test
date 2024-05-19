variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "random_s3" {
  type = map(bool)
  default = {
    "special" = false
    "upper  " = false
    "numeric" = false
  }
}

variable "tags" {
  type = map(any)
  default = {
    "id"             = "1119"
    "owner"          = "tcc"
    "teams"          = "Devops"
    "environment"    = "development"
    "project"        = "a1"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

variable "s3_versioning" {
  type    = string
  default = "Enabled"
}