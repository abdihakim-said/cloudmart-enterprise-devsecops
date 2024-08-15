# Database Module Outputs

output "products_table_name" {
  description = "Name of the products DynamoDB table"
  value       = aws_dynamodb_table.products.name
}

output "products_table_arn" {
  description = "ARN of the products DynamoDB table"
  value       = aws_dynamodb_table.products.arn
}

output "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.name
}

output "orders_table_arn" {
  description = "ARN of the orders DynamoDB table"
  value       = aws_dynamodb_table.orders.arn
}

output "orders_stream_arn" {
  description = "ARN of the orders DynamoDB stream"
  value       = aws_dynamodb_table.orders.stream_arn
}

output "tickets_table_name" {
  description = "Name of the tickets DynamoDB table"
  value       = aws_dynamodb_table.tickets.name
}

output "tickets_table_arn" {
  description = "ARN of the tickets DynamoDB table"
  value       = aws_dynamodb_table.tickets.arn
}

output "users_table_name" {
  description = "Name of the users DynamoDB table"
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "ARN of the users DynamoDB table"
  value       = aws_dynamodb_table.users.arn
}
