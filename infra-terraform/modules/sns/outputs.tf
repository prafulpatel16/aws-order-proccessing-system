output "sns_topic_arn" {
  value       = aws_sns_topic.order_notifications.arn
  description = "ARN of the SNS topic"
}