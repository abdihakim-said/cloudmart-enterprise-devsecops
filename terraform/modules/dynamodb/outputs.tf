# DynamoDB Module Outputs

# Products Table
output "products_table_name" {
  description = "Name of the products DynamoDB table"
  value       = aws_dynamodb_table.cloudmart_products.name
}

output "products_table_arn" {
  description = "ARN of the products DynamoDB table"
  value       = aws_dynamodb_table.cloudmart_products.arn
}

# Orders Table
output "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = aws_dynamodb_table.cloudmart_orders.name
}

output "orders_table_arn" {
  description = "ARN of the orders DynamoDB table"
  value       = aws_dynamodb_table.cloudmart_orders.arn
}

output "orders_stream_arn" {
  description = "ARN of the orders DynamoDB stream"
  value       = aws_dynamodb_table.cloudmart_orders.stream_arn
}

# Tickets Table
output "tickets_table_name" {
  description = "Name of the tickets DynamoDB table"
  value       = aws_dynamodb_table.cloudmart_tickets.name
}

output "tickets_table_arn" {
  description = "ARN of the tickets DynamoDB table"
  value       = aws_dynamodb_table.cloudmart_tickets.arn
}
