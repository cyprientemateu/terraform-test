provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "ecr-cleanup-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr-cleanup-policy"
  description = "Policy for ECR cleanup"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:BatchDeleteImage",
          "ecr:DescribeImages"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_lambda_function" "ecr_cleanup" {
  filename         = "lambda_function_payload.zip"
  function_name    = "ecr-cleanup-function"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "cleanup.lambda_handler"
  runtime          = "python3.9"
  timeout          = 300
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "daily-ecr-cleanup"
  description         = "Daily trigger for ECR cleanup"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "ecr-cleanup-target"
  arn       = aws_lambda_function.ecr_cleanup.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecr_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}
