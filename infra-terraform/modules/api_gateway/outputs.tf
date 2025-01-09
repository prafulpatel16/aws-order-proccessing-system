# Output the API Gateway URL
output "api_gateway_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
  description = "The URL of the deployed API Gateway"
}