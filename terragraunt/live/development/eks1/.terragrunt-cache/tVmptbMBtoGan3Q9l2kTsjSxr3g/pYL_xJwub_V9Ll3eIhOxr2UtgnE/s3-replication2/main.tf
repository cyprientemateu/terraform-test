
resource "aws_iam_role" "tcc_replication_role" {
  provider           = aws.state
  name               = format("tcc-replication-role-%s-%s", var.tags["id"], var.tags["project"])
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = var.tags
}

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

resource "aws_iam_role_policy_attachment" "tcc_replication_policy_attachment" {
  provider   = aws.state
  role       = aws_iam_role.tcc_replication_role.name
  policy_arn = aws_iam_policy.tcc_replication_policy.arn
}

resource "aws_s3_bucket" "primary_bucket" {
  provider = aws.state
  bucket   = format("primary-bucket-%s-%s", var.tags["id"], var.tags["project"])

  lifecycle {
    prevent_destroy = false
  }
  tags = var.tags
}
resource "aws_s3_bucket_versioning" "primary_bucket" {
  provider = aws.state
  bucket   = aws_s3_bucket.primary_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "replica_bucket" {
  provider = aws.backup
  bucket   = format("replica-bucket-%s-%s", var.tags["id"], var.tags["project"])

  lifecycle {
    prevent_destroy = false
  }
  tags = var.tags
}
resource "aws_s3_bucket_versioning" "replica_bucket" {
  provider = aws.backup
  bucket   = aws_s3_bucket.replica_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.state
  depends_on = [
    aws_s3_bucket_versioning.primary_bucket,
    aws_s3_bucket_versioning.replica_bucket
  ]

  role   = aws_iam_role.tcc_replication_role.arn
  bucket = aws_s3_bucket.primary_bucket.id

  rule {
    id = "StateReplicationAll"

    filter {
      prefix = ""
    }

    status = "Enabled"


    destination {
      bucket        = aws_s3_bucket.replica_bucket.arn
      storage_class = "STANDARD"
    }


    delete_marker_replication {
      status = "Enabled"
    }
  }
}









