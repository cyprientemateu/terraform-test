terraform {
  backend "s3" {
    bucket         = var.backend["bucket"]
    dynamodb_table = var.backend["dynamo_table"]
    key            = var.backend["key"]
    region         = var.backend["region"]
    encrypt        = true
  }
}