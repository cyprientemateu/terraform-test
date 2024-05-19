resource "aws_dynamodb_table" "tcc_dynamodb" {
  provider       = aws.state
  name           = format("dynamodb-%s-%s", var.tags["id"], var.tags["project"])
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = var.tags
}