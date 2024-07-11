resource "aws_iam_policy" "tcc_replication_policy" {
  provider    = aws.state
  name        = format("tcc-replication-policy-%s-%s", var.tags["id"], var.tags["project"])
  description = "Policy to allow S3 cross-region replication"

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.primary_bucket.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging",
        "s3:PutBucketVersioning"
      ],
      "Resource": ["${aws_s3_bucket.primary_bucket.arn}/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:ReplicateObjectTagging"
      ],
      "Resource": ["${aws_s3_bucket.replica_bucket.arn}/*"]
    }
  ]
}
EOF
}










