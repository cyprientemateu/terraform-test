terraform {
  backend "s3" {
    bucket         = ""
    dynamodb_table = ""
    key            = "TCC/aurora-PostgreSQL-db/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}