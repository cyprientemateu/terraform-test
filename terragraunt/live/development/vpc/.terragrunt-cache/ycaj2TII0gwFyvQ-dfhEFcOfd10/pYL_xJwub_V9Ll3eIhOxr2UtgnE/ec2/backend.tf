# terraform {
#   backend "s3" {
#     bucket         = "main-backend-tcc-1119"
#     dynamodb_table = "dynamodb-tcc-1119"
#     key            = "teraform-test/ec2/terraform.tfstate"
#     region         = "us-east-1"
#   }
# }