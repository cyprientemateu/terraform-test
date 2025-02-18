resource "aws_iam_role" "flow_log_role" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "VPC-Flow-Log-Role"
  }
}

resource "aws_iam_policy" "vpc_flow_log_policy" {
  name        = "VpcFlowLogPolicy"
  description = "Policy to allow VPC Flow Logs to publish to CloudWatch Logs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "flow_log_policy_attachment" {
  name       = "vpc-flow-log-policy-attachment"
  roles      = [aws_iam_role.flow_log_role.name]
  policy_arn = aws_iam_policy.vpc_flow_log_policy.arn
}

resource "aws_flow_log" "primary_vpc_flow_log" {
  vpc_id = aws_vpc.primary_vpc.id
  # log_group_name = "primary-vpc-flow-logs"
  log_destination = "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:primary-vpc-flow-logs"
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  traffic_type    = "ALL"

  tags = {
    Name = "primary-vpc-flow-logs"
  }
}

resource "aws_flow_log" "secondary_vpc_flow_log" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id
  # log_group_name  = "secondary-vpc-flow-logs"
  log_destination = "arn:aws:logs:us-west-2:${data.aws_caller_identity.current.account_id}:log-group:secondary-vpc-flow-logs"
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  traffic_type    = "ALL"

  tags = {
    Name = "secondary-vpc-flow-logs"
  }
}

data "aws_caller_identity" "current" {}