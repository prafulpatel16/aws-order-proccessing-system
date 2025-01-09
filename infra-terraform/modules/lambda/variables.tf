variable "s3_bucket" {
  description = "S3 bucket where Lambda function code is stored"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Environment for the deployment (e.g., production, staging)"
  default     = "production"
}

variable "lambda_functions" {
  description = "Map of Lambda functions and their configurations"
  type        = map(object({
    handler          = string
    runtime          = string
    s3_key           = string
    environment_vars = map(string)
  }))
}
