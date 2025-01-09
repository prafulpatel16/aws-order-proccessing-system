# Define the SNS topic
resource "aws_sns_topic" "order_notifications" {
  name = var.sns_topic_name
}

# Optional: Create an email subscription for the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = var.email_subscription

  depends_on = [aws_sns_topic.order_notifications]
}