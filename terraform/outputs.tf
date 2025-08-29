# CloudMart Infrastructure Outputs - Multi-Cloud Production Ready

# General Information
output "aws_region" {
  description = "AWS Region where resources are deployed"
  value       = var.aws_region
}

output "azure_location" {
  description = "Azure location where Text Analytics is deployed"
  value       = var.azure_location
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# DynamoDB Outputs - Exact table information from your configuration
output "dynamodb_tables" {
  description = "DynamoDB table information"
  value = {
    products = {
      name = module.dynamodb.products_table_name
      arn  = module.dynamodb.products_table_arn
    }
    orders = {
      name       = module.dynamodb.orders_table_name
      arn        = module.dynamodb.orders_table_arn
      stream_arn = module.dynamodb.orders_stream_arn
    }
    tickets = {
      name = module.dynamodb.tickets_table_name
      arn  = module.dynamodb.tickets_table_arn
    }
  }
}

# Lambda Outputs - Exact function information from your configuration
output "lambda_functions" {
  description = "Lambda function information"
  value = {
    list_products = {
      name = module.lambda.list_products_function_name
      arn  = module.lambda.list_products_function_arn
    }
    dynamodb_to_bigquery = {
      name = module.lambda.dynamodb_to_bigquery_function_name
      arn  = module.lambda.dynamodb_to_bigquery_function_arn
    }
  }
}

# Azure Text Analytics Outputs
output "azure_text_analytics" {
  description = "Azure Text Analytics service information"
  value = {
    name                = module.azure.text_analytics_name
    resource_group      = module.azure.resource_group_name
    location           = module.azure.azure_location
    aws_secret_name    = module.azure.aws_secret_name
    aws_secret_arn     = module.azure.aws_secret_arn
  }
  sensitive = true
}

# Multi-Cloud Integration
output "multi_cloud_integration" {
  description = "Multi-cloud service integration details"
  value = {
    aws_dynamodb_tables = [
      module.dynamodb.products_table_name,
      module.dynamodb.orders_table_name,
      module.dynamodb.tickets_table_name
    ]
    azure_text_analytics = module.azure.text_analytics_name
    gcp_bigquery = {
      project_id = var.google_project_id
      dataset    = var.bigquery_dataset
      table      = var.bigquery_table
    }
  }
}

# Key outputs for your application
output "products_table_name" {
  description = "Products table name for your application"
  value       = module.dynamodb.products_table_name
}

output "orders_table_name" {
  description = "Orders table name for your application"
  value       = module.dynamodb.orders_table_name
}

output "tickets_table_name" {
  description = "Tickets table name for your application"
  value       = module.dynamodb.tickets_table_name
}

output "list_products_function_arn" {
  description = "List products Lambda function ARN"
  value       = module.lambda.list_products_function_arn
}

# Deployment Information
output "deployment_summary" {
  description = "Summary of deployed multi-cloud infrastructure"
  value = {
    aws_resources = {
      region = var.aws_region
      dynamodb_tables = 3
      lambda_functions = 2
      secrets_manager = 1
      eks_cluster = 1
    }
    azure_resources = {
      location = var.azure_location
      text_analytics = 1
      resource_group = 1
    }
    gcp_integration = {
      bigquery_pipeline = "enabled"
      project_id = var.google_project_id
    }
  }
}

# EKS Cluster Outputs
output "eks_cluster" {
  description = "EKS cluster information"
  value = {
    cluster_id       = module.eks.cluster_id
    cluster_arn      = module.eks.cluster_arn
    cluster_endpoint = module.eks.cluster_endpoint
    vpc_id          = module.eks.vpc_id
  }
  sensitive = true
}
