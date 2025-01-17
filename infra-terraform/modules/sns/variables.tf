variable "email_subscription" {
  description = "Email address to subscribe to SNS topic for notifications"
  type        = string
  default     = ""  # Set a default or leave empty if not needed
}
variable "sns_topic_name" {
  description = "The name of the SNS topic for order notifications"
  type        = string
}