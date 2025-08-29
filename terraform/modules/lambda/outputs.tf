# Lambda Module Outputs

output "list_products_function_arn" {
  description = "ARN of the list products Lambda function"
  value       = aws_lambda_function.list_products.arn
}

output "list_products_function_name" {
  description = "Name of the list products Lambda function"
  value       = aws_lambda_function.list_products.function_name
}

output "dynamodb_to_bigquery_function_arn" {
  description = "ARN of the DynamoDB to BigQuery Lambda function"
  value       = aws_lambda_function.dynamodb_to_bigquery.arn
}

output "dynamodb_to_bigquery_function_name" {
  description = "Name of the DynamoDB to BigQuery Lambda function"
  value       = aws_lambda_function.dynamodb_to_bigquery.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}
