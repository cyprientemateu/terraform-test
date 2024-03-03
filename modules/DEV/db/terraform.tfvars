aws_region = "us-east-1"

vpc_id                  = "vpc-026a1034816688c1d"
subnet_ids              = ["subnet-02e286c9bdfb33f0b", "subnet-011cf4a50c2518de6"]
avalability_zones       = ["us-east-1a", "us-east-1b"]
instance_count          = 2
instance_class          = "db.r5.large"
engine_version          = "11.9"
backup_retention_period = 7
preferred_backup_window = "02:00-03:00"

backend = {
  bucket         = ""
  dynamodb_table = ""
  key            = ""
  region         = ""
}