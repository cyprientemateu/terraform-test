resource "aws_s3_bucket" "main-backend" {
  provider = aws.main
  bucket   = format("%s-%s-main-backend", var.tags["id"], var.tags["project"])

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
  provider = aws.backup
  bucket   = format("%s-%s-backup-backend", var.tags["id"], var.tags["project"])

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "backup-backend" {
  provider = aws.backup
  bucket   = aws_s3_bucket.backup-backend.id
  versioning_configuration {
    status = "Enabled"
  }
}
