terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  alias  = "main"
  region = "us-east-1" # Main bucket region
}

provider "aws" {
  alias  = "backup_us_east"
  region = "us-east-2" # Backup bucket region 1
}

provider "aws" {
  alias  = "backup_us_west"
  region = "us-west-1" # Backup bucket region 2
}

resource "aws_dynamodb_table" "tcc_dynamodb" {
  provider       = aws.main
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

resource "aws_iam_role" "tcc_replication_role" {
  provider           = aws.main
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
  name        = "replication_policy"
  description = "Policy to allow S3 cross-region replication"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ]
      Resource = [
        "${aws_s3_bucket.primary_bucket.arn}"
      ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:PutBucketVersioning"
        ]
        Resource = [
          "${aws_s3_bucket.primary_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateTags",
          "s3:ReplicateObjectTagging"
        ]
        Resource = [
          "${aws_s3_bucket.replica_bucket_us_east.arn}/*",
          "${aws_s3_bucket.replica_bucket_us_west.arn}/*"
        ]
    }]
  })
}

# resource "aws_iam_policy" "tcc_replication_policy" {
#   provider    = aws.main
#   name        = format("tcc-replication-policy-%s-%s", var.tags["id"], var.tags["project"])
#   description = "Policy to allow S3 cross-region replication"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:GetReplicationConfiguration",
#         "s3:ListBucket"
#       ],
#       "Resource": [
#         "${aws_s3_bucket.primary_bucket.arn}"
#       ]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:GetObjectVersionForReplication",
#         "s3:GetObjectVersionAcl",
#         "s3:GetObjectVersionTagging",
#         "s3:PutBucketVersioning"
#       ],
#       "Resource": ["${aws_s3_bucket.primary_bucket.arn}/*"]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:ReplicateObject",
#         "s3:ReplicateTags",
#         "s3:ReplicateObjectTagging"
#       ],
#       "Resource": ["${aws_s3_bucket.replica_bucket_us_east.arn}/*", "${aws_s3_bucket.replica_bucket_us_west.arn}/*"]
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role_policy_attachment" "tcc_replication_policy_attachment" {
  provider   = aws.main
  role       = aws_iam_role.tcc_replication_role.name
  policy_arn = aws_iam_policy.tcc_replication_policy.arn
}

resource "aws_s3_bucket" "primary_bucket" {
  provider = aws.main
  bucket   = format("primary-bucket-%s-%s", var.tags["id"], var.tags["project"])

  lifecycle {
    prevent_destroy = false
  }
  tags = var.tags
}
resource "aws_s3_bucket_versioning" "primary_bucket" {
  provider = aws.main
  bucket   = aws_s3_bucket.primary_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "replica_bucket_us_east" {
  provider = aws.backup_us_east
  bucket   = format("replica-bucket-us-east-%s-%s", var.tags["id"], var.tags["project"])

  lifecycle {
    prevent_destroy = false
  }
  tags = var.tags
}
resource "aws_s3_bucket_versioning" "replica_bucket_us_east" {
  provider = aws.backup_us_east
  bucket   = aws_s3_bucket.replica_bucket_us_east.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "replica_bucket_us_west" {
  provider = aws.backup_us_west
  bucket   = format("replica-bucket-us-west-%s-%s", var.tags["id"], var.tags["project"])

  lifecycle {
    prevent_destroy = false
  }
  tags = var.tags
}
resource "aws_s3_bucket_versioning" "replica_bucket_us_west" {
  provider = aws.backup_us_west
  bucket   = aws_s3_bucket.replica_bucket_us_west.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "aws_s3_bucket_replication_configuration" "replication" {
#   provider = aws.main
#   depends_on = [
#     aws_s3_bucket_versioning.primary_bucket,
#     aws_s3_bucket_versioning.replica_bucket_us_east,
#     aws_s3_bucket_versioning.replica_bucket_us_west
#   ]

#   role   = aws_iam_role.tcc_replication_role.arn
#   bucket = aws_s3_bucket.primary_bucket.id

#   rule {
#     id     = "a1cyprien"
#     status = "Enabled"

#     destination {
#       bucket = [
#         "aws_s3_bucket.replica_bucket_us_east.arn",
#         "aws_s3_bucket.replica_bucket_us_west.arn"
#       ]
#       storage_class = "STANDARD"
#     }
#   }
# }

resource "aws_s3_bucket_replication_configuration" "replication_us_east" {
  provider = aws.main
  depends_on = [
    aws_s3_bucket_versioning.replica_bucket_us_west,
    aws_s3_bucket_versioning.replica_bucket_us_east
  ]

  role   = aws_iam_role.tcc_replication_role.arn
  bucket = aws_s3_bucket.primary_bucket.id

  rule {
    id     = "replicate_to_us_east"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica_bucket_us_east.arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "replication_us_west" {
  provider = aws.main
  depends_on = [
    aws_s3_bucket_versioning.replica_bucket_us_east,
    aws_s3_bucket_versioning.replica_bucket_us_west
  ]

  role   = aws_iam_role.tcc_replication_role.arn
  bucket = aws_s3_bucket.primary_bucket.id

  rule {
    id     = "replicate_to_us_west"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replica_bucket_us_west.arn
      storage_class = "STANDARD"
    }
  }
}
