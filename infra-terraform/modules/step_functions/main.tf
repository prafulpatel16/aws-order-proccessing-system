# Fetch the IAM Role ARN for Step Functions
data "aws_iam_role" "step_functions_role" {
  name = "${var.state_machine_name}_role"
}

# Create Step Functions State Machine
resource "aws_sfn_state_machine" "order_processing" {
  name     = var.state_machine_name
  role_arn = data.aws_iam_role.step_functions_role.arn

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