output "orders_table_name" {
  description = "Name of the Orders DynamoDB table"
  value       = aws_dynamodb_table.orders.name
}

output "inventory_table_name" {
  description = "Name of the Inventory DynamoDB table"
  value       = aws_dynamodb_table.inventory.name
}
