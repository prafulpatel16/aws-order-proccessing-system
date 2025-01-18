provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}


# S3 Module
module "s3" {
  source        = "./modules/s3"
  web_bucket    = var.web_bucket
  lambda_bucket = var.lambda_bucket
  index_doc     = var.index_doc
  error_doc     = var.error_doc
}

# API Gateway Module
module "api_gateway" {
  source              = "./modules/api_gateway"
  api_name            = var.api_name
  lambda_function_arn = module.lambda.lambda_arns["orderPlacement"]
  stage_name          = var.stage_name
  aws_region          = var.aws_region
}

# Define the S3 bucket for Lambda deployment
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket
  acl    = "private"


}

# Lambda Module
module "lambda" {
  source        = "./modules/lambda"
  lambda_bucket = aws_s3_bucket.lambda_bucket.bucket
  aws_region    = var.aws_region
  environment   = var.environment

  #  lambda_bucket = aws_s3_bucket.lambda_bucket.id  # Pass the bucket ID

  lambda_functions = {
    "orderPlacement" = {
      handler = "orderPlacement.lambda_handler"
      runtime = "python3.8"
      s3_key  = "A-orderPlacement.zip"
      environment_vars = {
        STATE_MACHINE_ARN = var.state_machine_arn
      }
    },
    "saveOrder" = {
      handler = "saveOrder.lambda_handler"
      runtime = "python3.8"
      s3_key  = "B.1-SaveOrder.zip"
      environment_vars = {
        DYNAMODB_TABLE_NAME = var.dynamodb_orders_table
      }
    },
    "validateOrder" = {
      handler = "validateOrder.lambda_handler"
      runtime = "python3.8"
      s3_key  = "B-validateOrder.zip"
      environment_vars = {
        INVENTORY_TABLE_NAME = var.dynamodb_inventory_table
      }
    },
    "updateInventory" = {
      handler = "updateInventory.lambda_handler"
      runtime = "python3.8"
      s3_key  = "D-updateInventory.zip"
      environment_vars = {
        INVENTORY_TABLE_NAME = var.dynamodb_inventory_table
      }
    },
    "processPayment" = {
      handler = "processPayment.lambda_handler"
      runtime = "python3.8"
      s3_key  = "C-processPayment.zip"
      environment_vars = {
        PAYMENT_GATEWAY_API_KEY = var.payment_gateway_api_key
      }
    }
  }
}



resource "aws_iam_role" "step_functions_role" {
  name = "step_functions_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "states.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_functions_policy" {
  role = aws_iam_role.step_functions_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction", "sns:Publish"]
        Resource = "*"
      }
    ]
  })
}




module "step_functions" {
  source               = "./modules/step_functions"
  state_machine_name   = var.state_machine_name
  role_arn             = aws_iam_role.step_functions_role.arn # Use IAM role from the module
  validate_order_arn   = module.lambda.lambda_arns["validateOrder"]
  process_payment_arn  = module.lambda.lambda_arns["processPayment"]
  update_inventory_arn = module.lambda.lambda_arns["updateInventory"]
  sns_topic_arn        = module.sns.sns_topic_arn
  sns_topic_name       = var.sns_topic_name
  aws_region           = var.aws_region
  environment          = var.environment
}

module "sns" {
  source = "./modules/sns"

  sns_topic_name     = "order_notifications"
  email_subscription = "praful.can1611@gmail.com"
}
