resource "aws_s3_bucket" "tcc_s3_backend" {
  bucket = format("%s-${random_string.tcc_random_str_s3.result}-statefile", var.tags["id"])

  tags = merge(var.tags, {
    Name = "tcc_s3_backend"
  })
}