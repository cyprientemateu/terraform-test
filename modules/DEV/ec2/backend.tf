terraform {
  backend "s3" {
    bucket         = "cyprienbucket"
    dynamodb_table = "terraform-lock"
    key            = "tcc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}