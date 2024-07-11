variable "aws_region" {
  type        = string
  description = "your desire aws region"
  default     = "us-east-1"
}

variable "tags" {
  type = map(any)
  default = {
    "id"             = "1119"
    "owner"          = "tcc"
    "teams"          = "devops"
    "environment"    = "development"
    "project"        = "a1-ecr"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

variable "backend" {
  type = map(string)
  default = {
    bucket         = ""
    dynamodb_table = ""
    key            = ""
    region         = ""
  }
}

variable "ecr_repo_name" {
  type = list(string)
}
variable "scan_on_push" {
  type    = bool
  default = true
}
variable "mutability" {
  type    = string
  default = "MUTABLE"

}

variable "scan_config" {
  type = map(string)
  default = {
    "scan_type"      = "BASIC"
    "scan_frequency" = "SCAN_ON_PUSH"
    "filter"         = "*"
  }
}



