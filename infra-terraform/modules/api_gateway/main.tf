# Create the API Gateway REST API
resource "aws_api_gateway_rest_api" "order_api" {
  name = var.api_name
}

# Create the /place-order resource
resource "aws_api_gateway_resource" "place_order" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  parent_id   = aws_api_gateway_rest_api.order_api.root_resource_id
  path_part   = "place-order"
}

# Define the POST method for /place-order
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.order_api.id
  resource_id   = aws_api_gateway_resource.place_order.id
  http_method   = "POST"
  authorization = "NONE"  # Adjust to "AWS_IAM" or other mechanisms as needed
}

# Integrate the POST method with Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.order_api.id
  resource_id             = aws_api_gateway_resource.place_order.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"

  depends_on = [aws_api_gateway_method.post_method]
}

# Grant permission to API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.order_api.execution_arn}/*/*"
}

# Create the deployment for the API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.order_api.id
  stage_name  = var.stage_name

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

# Define usage plan and API key (optional)
resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "${var.api_name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.order_api.id
    stage  = aws_api_gateway_deployment.api_deployment.stage_name
  }
}