terraform {
  backend "s3" {
    bucket         = ""
    dynamodb_table = ""
    key            = "TCC/ec2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}