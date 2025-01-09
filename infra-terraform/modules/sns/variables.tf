variable "sns_topic_name" {
  description = "Name of the SNS topic for order notifications"
  type        = string
}

variable "email_subscription" {
  description = "Email address to subscribe to SNS topic for notifications"
  type        = string
  default     = ""  # Set a default or leave empty if not needed
}
