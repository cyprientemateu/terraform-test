resource "aws_dynamodb_table" "tcc_dynamodb" {
  name           = format("dynamodb-${random_string.tcc_random_str_s3.result}-%s", var.tags["id"])
  hash_key       = "BEWARE"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "BEWARE"
    type = "S"
  }
}