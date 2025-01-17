variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket for Lambda deployment"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket for frontend deployment"
  type        = string
}

variable "index_doc" {
  description = "Index document for S3 bucket"
  type        = string
}

variable "error_doc" {
  description = "Error document for S3 bucket"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Stage name for API Gateway"
  type        = string
}

variable "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  type        = string
}

variable "dynamodb_orders_table" {
  description = "Name of the Orders DynamoDB table"
  type        = string
}

variable "dynamodb_inventory_table" {
  description = "Name of the Inventory DynamoDB table"
  type        = string
}

variable "payment_gateway_api_key" {
  description = "API key for the payment gateway"
  type        = string
}

variable "orders_table_name" {
  description = "Name of the Orders table"
  type        = string
}

variable "inventory_table_name" {
  description = "Name of the Inventory table"
  type        = string
}

variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "sns_topic_name" {
  description = "The name of the SNS topic for order notifications"
  type        = string
}

variable "email_subscription" {
  description = "Email address for SNS subscription"
  type        = string
  default     = "" # Set a default or leave empty if not needed
}
