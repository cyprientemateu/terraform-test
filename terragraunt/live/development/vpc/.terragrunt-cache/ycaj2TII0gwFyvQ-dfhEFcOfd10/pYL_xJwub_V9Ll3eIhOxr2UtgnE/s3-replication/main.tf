resource "aws_s3_bucket" "main-backend" {
  provider      = aws.main
  force_destroy = var.force_destroy
  bucket        = format("main-backend-%s-%s", var.tags["owner"], var.tags["id"])

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "main-backend" {
  provider = aws.main
  bucket   = aws_s3_bucket.main-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "backup-backend" {
  provider      = aws.backup
  force_destroy = var.force_destroy
  bucket        = format("backup-backend-%s-%s", var.tags["owner"], var.tags["id"])

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "backup-backend" {
  provider = aws.backup
  bucket   = aws_s3_bucket.backup-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}
