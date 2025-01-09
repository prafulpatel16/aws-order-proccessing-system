# Create the Orders DynamoDB Table
resource "aws_dynamodb_table" "orders" {
  name         = var.orders_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }

  tags = {
    Environment = var.environment
  }
}

# Create the Inventory DynamoDB Table
resource "aws_dynamodb_table" "inventory" {
  name         = var.inventory_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "productId"

  attribute {
    name = "productId"
    type = "S"
  }

  tags = {
    Environment = var.environment
  }
}

# Insert Sample Data into the Inventory Table using local-exec provisioner
resource "null_resource" "inventory_sample_data" {
  provisioner "local-exec" {
    command = <<EOT
      aws dynamodb put-item --table-name ${aws_dynamodb_table.inventory.name} --item '{"productId": {"S": "PROD1001"}, "productName": {"S": "Laptop"}, "quantity": {"N": "50"}}' --region ${var.aws_region}
      aws dynamodb put-item --table-name ${aws_dynamodb_table.inventory.name} --item '{"productId": {"S": "PROD1002"}, "productName": {"S": "Smartphone"}, "quantity": {"N": "100"}}' --region ${var.aws_region}
      aws dynamodb put-item --table-name ${aws_dynamodb_table.inventory.name} --item '{"productId": {"S": "PROD1003"}, "productName": {"S": "Tablet"}, "quantity": {"N": "30"}}' --region ${var.aws_region}
    EOT
  }

  depends_on = [aws_dynamodb_table.inventory]
}
