variable "api_name" {
  description = "Name of the API Gateway"
  default     = "OrderProcessingAPI"
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to integrate with API Gateway"
}

variable "stage_name" {
  description = "Deployment stage for API Gateway"
  default     = "prod"
}
variable "aws_region" {
  description = "AWS region for the API Gateway"
  type        = string
}
