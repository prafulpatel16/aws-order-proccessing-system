
# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# IAM Role Policy Document
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Attach AWS Managed Policies to Lambda Role
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  for_each = toset([
    "service-role/AWSLambdaBasicExecutionRole",
    "service-role/AWSLambdaVPCAccessExecutionRole"
  ])

  name       = "attach-${each.value}"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Lambda function

resource "aws_lambda_function" "lambda_function" {
  for_each          = var.lambda_functions

  function_name     = each.key
  handler           = each.value.handler
  runtime           = each.value.runtime
  role              = aws_iam_role.lambda_role.arn

  # Use the filename from S3
  s3_bucket         = var.s3_bucket
  s3_key            = each.value.s3_key

  environment {
    variables = merge(each.value.environment_vars, {
      AWS_REGION = var.aws_region
    })
  }

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}