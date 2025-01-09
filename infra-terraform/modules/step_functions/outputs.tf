output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.order_processing.arn
}
# Export the Role ARN
output "role_arn" {
  value       = aws_iam_role.step_functions_role.arn
  description = "The ARN of the Step Functions IAM role"
}