resource "aws_s3_bucket_versioning" "tcc_s3_versioning" {
  bucket = aws_s3_bucket.tcc_s3_backend.id
  versioning_configuration {
    status = var.s3_versioning
  }
}