provider "aws" {
  region = var.aws_region
}

# S3 Module
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  index_doc   = var.index_doc
  error_doc   = var.error_doc
}

# API Gateway Module
module "api_gateway" {
  source              = "./modules/api_gateway"
  api_name            = var.api_name
  lambda_function_arn = module.lambda.lambda_arns["orderPlacement"]
  stage_name          = var.stage_name
  aws_region          = var.aws_region
}

# Lambda Module
module "lambda" {
  source       = "./modules/lambda"
  s3_bucket    = var.s3_bucket
  aws_region   = var.aws_region
  environment  = var.environment

  lambda_functions = {
    "orderPlacement" = {
      handler          = "orderPlacement.lambda_handler"
      runtime          = "python3.8"
      s3_key           = "A-orderPlacement.zip"
      environment_vars = {
        STATE_MACHINE_ARN = var.state_machine_arn
      }
    },
    "saveOrder" = {
      handler          = "saveOrder.lambda_handler"
      runtime          = "python3.8"
      s3_key           = "B.1-SaveOrder.zip"
      environment_vars = {
        DYNAMODB_TABLE_NAME = var.dynamodb_orders_table
      }
    },
    "validateOrder" = {
      handler          = "validateOrder.lambda_handler"
      runtime          = "python3.8"
      s3_key           = "B-validateOrder.zip"
      environment_vars = {
        INVENTORY_TABLE_NAME = var.dynamodb_inventory_table
      }
    },
    "updateInventory" = {
      handler          = "updateInventory.lambda_handler"
      runtime          = "python3.8"
      s3_key           = "D-updateInventory.zip"
      environment_vars = {
        INVENTORY_TABLE_NAME = var.dynamodb_inventory_table
      }
    },
    "processPayment" = {
      handler          = "processPayment.lambda_handler"
      runtime          = "python3.8"
      s3_key           = "C-processPayment.zip"
      environment_vars = {
        PAYMENT_GATEWAY_API_KEY = var.payment_gateway_api_key
      }
    }
  }
}


# Create IAM Role for Step Functions in the root module
resource "aws_iam_role" "step_functions_role" {
  name               = "${var.state_machine_name}_role"
  assume_role_policy = data.aws_iam_policy_document.step_functions_assume_role_policy.json
}

data "aws_iam_policy_document" "step_functions_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "step_functions_execution_policy" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSStepFunctionsFullAccess"
}


module "step_functions" {
  source              = "./modules/step_functions"
  state_machine_name  = var.state_machine_name
  role_arn            = module.step_functions.step_functions_role.arn  # Use IAM role from the module
  validate_order_arn  = module.lambda.lambda_arns["validateOrder"]
  process_payment_arn = module.lambda.lambda_arns["processPayment"]
  update_inventory_arn = module.lambda.lambda_arns["updateInventory"]
  sns_topic_arn       = module.sns.sns_topic_arn
  aws_region          = var.aws_region
  environment         = var.environment
}
