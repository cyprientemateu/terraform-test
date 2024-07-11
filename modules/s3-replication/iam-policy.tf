resource "aws_iam_policy" "replication" {
  name   = format("%s-%s-s3-role-policy-replication", var.tags["id"], var.tags["project"])
  policy = data.aws_iam_policy_document.replication.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.main-backend.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:PutBucketVersioning",
    ]

    resources = ["${aws_s3_bucket.main-backend.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
      "s3:ReplicateObjectTagging"
    ]

    resources = ["${aws_s3_bucket.backup-backend.arn}/*"]
  }
}


