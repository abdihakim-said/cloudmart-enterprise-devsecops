# CloudMart Infrastructure Outputs

# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

# EKS Outputs
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

# Database Outputs
output "products_table_name" {
  description = "Name of the products DynamoDB table"
  value       = module.database.products_table_name
}

output "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = module.database.orders_table_name
}

output "tickets_table_name" {
  description = "Name of the tickets DynamoDB table"
  value       = module.database.tickets_table_name
}

# Lambda Outputs
output "list_products_function_arn" {
  description = "ARN of the list products Lambda function"
  value       = module.lambda.list_products_function_arn
}

output "dynamodb_to_bigquery_function_arn" {
  description = "ARN of the DynamoDB to BigQuery Lambda function"
  value       = module.lambda.dynamodb_to_bigquery_function_arn
}

# ECR Outputs
output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value       = module.ecr.repository_urls
}

# Observability Outputs
output "prometheus_endpoint" {
  description = "Prometheus endpoint URL"
  value       = module.observability.prometheus_endpoint
}

output "grafana_endpoint" {
  description = "Grafana endpoint URL"
  value       = module.observability.grafana_endpoint
}

output "observability_bucket" {
  description = "S3 bucket for observability data"
  value       = module.observability.observability_bucket
}
