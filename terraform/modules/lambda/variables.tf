# Lambda Module Variables - Production Best Practices

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "nodejs20.x"
  
  validation {
    condition = can(regex("^nodejs(18|20)\\.x$", var.lambda_runtime))
    error_message = "Lambda runtime must be nodejs18.x or nodejs20.x."
  }
}

# DynamoDB table references - exact from your configuration
variable "products_table_name" {
  description = "Name of the products DynamoDB table"
  type        = string
}

variable "products_table_arn" {
  description = "ARN of the products DynamoDB table"
  type        = string
}

variable "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  type        = string
}

variable "orders_table_arn" {
  description = "ARN of the orders DynamoDB table"
  type        = string
}

variable "orders_stream_arn" {
  description = "ARN of the orders DynamoDB stream"
  type        = string
}

variable "tickets_table_name" {
  description = "Name of the tickets DynamoDB table"
  type        = string
}

variable "tickets_table_arn" {
  description = "ARN of the tickets DynamoDB table"
  type        = string
}

# BigQuery configuration - exact values from your setup
variable "google_project_id" {
  description = "Google Cloud Project ID for BigQuery"
  type        = string
}

variable "bigquery_dataset" {
  description = "BigQuery dataset name"
  type        = string
}

variable "bigquery_table" {
  description = "BigQuery table name"
  type        = string
}

# Multi-cloud integration
variable "azure_secret_arn" {
  description = "ARN of AWS Secrets Manager secret containing Azure Text Analytics credentials"
  type        = string
}

variable "gcp_secret_arn" {
  description = "ARN of AWS Secrets Manager secret containing GCP BigQuery credentials"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
