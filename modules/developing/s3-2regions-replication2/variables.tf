variable "primary_region" {
  description = "The primary region for S3 bucket deployment."
  type        = string
  default     = "us-east-1"
}

variable "replica_region1" {
  description = "The replica region for S3 bucket deployment."
  type        = string
  default     = "us-west-1"
}

variable "replica_region2" {
  description = "The replica region for S3 bucket deployment."
  type        = string
  default     = "us-east-2"
}

variable "s3_versioning" {
  type    = string
  default = "Enabled"
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
