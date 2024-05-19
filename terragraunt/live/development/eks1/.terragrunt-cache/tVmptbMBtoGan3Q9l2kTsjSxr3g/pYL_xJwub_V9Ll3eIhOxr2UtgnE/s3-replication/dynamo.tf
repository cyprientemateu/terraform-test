resource "aws_dynamodb_table" "tcc1_dynamodb" {
  provider       = aws.main
  name           = format("dynamodb-%s-%s", var.tags["owner"], var.tags["id"])
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = var.tags
}