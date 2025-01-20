# IAM Role for Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_start_stop_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_start_stop_ec2_policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "logs:*"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "ec2_start_stop" {
  filename         = "start_stop_ec2.zip" # Zip file containing your Python script
  function_name    = "start_stop_ec2"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("start_stop_ec2.zip")

  environment {
    variables = {
      TAG_KEY   = "jenkins"
      TAG_VALUE = "true"
    }
  }
}

# CloudWatch Event Rules for Scheduling
resource "aws_cloudwatch_event_rule" "start_instances" {
  name                = "start_ec2_weekdays"
  schedule_expression = "cron(30 13 ? * MON-FRI *)" # 8:30 AM EST (adjust for UTC offset)
}

resource "aws_cloudwatch_event_rule" "stop_instances" {
  name                = "stop_ec2_weekdays"
  schedule_expression = "cron(30 0 ? * MON-FRI *)" # 7:30 PM EST (adjust for UTC offset)
}

# CloudWatch Event Target - Start Instances
resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_instances.name
  target_id = "start-ec2"
  arn       = aws_lambda_function.ec2_start_stop.arn
  input     = jsonencode({ action = "start" })
}

# CloudWatch Event Target - Stop Instances
resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_instances.name
  target_id = "stop-ec2"
  arn       = aws_lambda_function.ec2_start_stop.arn
  input     = jsonencode({ action = "stop" })
}

# Permission for Lambda to be Invoked by EventBridge
resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_instances.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_instances.arn
}
