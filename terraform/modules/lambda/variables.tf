# Lambda Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "products_table_name" {
  description = "Name of the products DynamoDB table"
  type        = string
}

variable "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  type        = string
}

variable "tickets_table_name" {
  description = "Name of the tickets DynamoDB table"
  type        = string
}

variable "orders_stream_arn" {
  description = "ARN of the orders DynamoDB stream"
  type        = string
}

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

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
