variable "primary_region" {
  description = "The primary region for S3 bucket deployment."
  type        = string
  default     = "us-east-1"
}

variable "replica_region" {
  description = "The replica region for S3 bucket deployment."
  type        = string
  default     = "us-east-2"
}

# variable "bucket_name" {
#   description = "The name of the S3 bucket."
#   type        = string
#   default     = "temateubucket"
# }

# variable "replica_bucket_name" {
#   description = "The name of the S3 bucket."
#   type        = string
#   default     = "carlos1bucket"
# }

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
