# Fetch the IAM Role ARN for Step Functions
#data "aws_iam_role" "step_functions_role" {
#  name = "${var.state_machine_name}_role"
#}

# Define the SNS topic
resource "aws_sns_topic" "order_notifications" {
  name = var.sns_topic_name
}
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.order_notifications.arn
  protocol  = "email"
  endpoint  = var.email_subscription
}

# Define the IAM role
resource "aws_iam_role" "step_functions_role" {
  name = "${var.state_machine_name}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy" "step_functions_policy" {
  role   = aws_iam_role.step_functions_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction", "sns:Publish"]
        Resource = [
          var.validate_order_arn,
          var.process_payment_arn,
          var.update_inventory_arn,
          var.sns_topic_arn
        ]
      }
    ]
  })
}


# Create Step Functions State Machine
resource "aws_sfn_state_machine" "order_processing" {
  name     = var.state_machine_name
  #role_arn = aws_iam_role.step_functions_role.arn
  role_arn = var.role_arn

  definition = jsonencode({
    Comment: "Order processing state machine",
    StartAt: "ValidateOrder",
    States: {
      ValidateOrder: {
        Type: "Task",
        Resource: var.validate_order_arn,
        Next: "ProcessPayment"
      },
      ProcessPayment: {
        Type: "Task",
        Resource: var.process_payment_arn,
        Next: "UpdateInventory"
      },
      UpdateInventory: {
        Type: "Task",
        Resource: var.update_inventory_arn,
        Next: "SendNotification"
      },
      SendNotification: {
        Type: "Task",
        Resource: var.sns_topic_arn,
        End: true
      }
    }
  })

  # Remove any duplicate 'definition' blocks here
}