variable "orders_table_name" {
  description = "Name of the Orders DynamoDB table"
  type        = string
}

variable "inventory_table_name" {
  description = "Name of the Inventory DynamoDB table"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}
