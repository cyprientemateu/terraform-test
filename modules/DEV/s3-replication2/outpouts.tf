output "primary_bucket_arn" {
  value = aws_s3_bucket.primary_bucket.arn
}

output "replica_bucket_arn" {
  value = aws_s3_bucket.replica_bucket.arn
}
