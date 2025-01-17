variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

variable "role_arn" {
  description = "IAM Role ARN for Step Functions execution"
  type        = string
}

variable "validate_order_arn" {
  description = "ARN of the ValidateOrder Lambda function"
  type        = string
}

variable "process_payment_arn" {
  description = "ARN of the ProcessPayment Lambda function"
  type        = string
}

variable "update_inventory_arn" {
  description = "ARN of the UpdateInventory Lambda function"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "email_subscription" {
  description = "Email address to subscribe to the SNS topic"
  type        = string
  default     = ""
}
variable "sns_topic_name" {
  description = "The name of the SNS topic for order notifications"
  type        = string
}