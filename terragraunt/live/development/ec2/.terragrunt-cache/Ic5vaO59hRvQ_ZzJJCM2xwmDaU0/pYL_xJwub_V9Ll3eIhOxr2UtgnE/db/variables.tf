variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "avalability_zones" {
  type = list(any)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

# variable "db_subnet_group_name" {
#   description = "Name of the DB subnet group"
# }

# variable "vpc_security_group_ids" {
#   description = "List of VPC security group IDs"
# }

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
  default     = "vpc-026a1034816688c1d"
}

variable "subnet_ids" {
  description = "The IDs of the subnets to include in the DB subnet group."
  type        = list(string)
  default     = ["subnet-02e286c9bdfb33f0b", "subnet-011cf4a50c2518de6"]
}

variable "cluster_identifier" {
  description = "The identifier for the RDS cluster."
  type        = string
  default     = "tcc-aurora-postgres-cluster"
}

variable "instance_class" {
  description = "The instance class for the RDS cluster instances."
  type        = string
  default     = "db.r5.large"
}

variable "engine_version" {
  description = "The version of the database engine to use."
  type        = string
  default     = "11.9"
}

variable "publicly_accessible" {
  description = "Specifies whether the RDS cluster instances can be publicly accessed."
  type        = bool
  default     = true
}

variable "engine" {
  description = "The engine of the database to use."
  type        = string
  default     = "aurora-postgresql"
}

variable "master_username" {
  description = "The username for the master user."
  type        = string
  default     = "carlos"
}

variable "database_name" {
  description = "The username for the master user."
  type        = string
  default     = "artifactory"
}

variable "backup_retention_period" {
  description = "The number of days during which automatic DB snapshots are retained."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "The daily time range for automated backups."
  type        = string
  default     = "07:00-09:00"
}

variable "backend" {
  type = map(string)
  default = {
    bucket         = "cyprienbucket"
    dynamodb_table = "terraform-lock"
    key            = "tcc-terraform/aurora-PostgreSQL-db/terraform.tfstate"
    region         = "us-east-1"
    # encrypt        = true
  }
}