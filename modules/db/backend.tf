terraform {
  backend "s3" {
    bucket         = "cyprienbucket"
    dynamodb_table = "terraform-lock"
    key            = "tcc-terraform/aurora-PostgreSQL-db/terraform.tfstate"
    region         = "us-east-1"
    # encrypt        = true
  }
}