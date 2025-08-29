# GCP Module Outputs

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.cloudmart.dataset_id
}

output "bigquery_table_id" {
  description = "BigQuery table ID"
  value       = google_bigquery_table.orders.table_id
}

output "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  value       = google_bigquery_dataset.cloudmart.location
}

output "service_account_email" {
  description = "Service account email for BigQuery access"
  value       = google_service_account.lambda_bigquery.email
}

output "service_account_key_id" {
  description = "Service account key ID"
  value       = google_service_account_key.lambda_bigquery_key.name
  sensitive   = true
}

output "aws_secret_arn" {
  description = "ARN of AWS Secrets Manager secret containing GCP credentials"
  value       = aws_secretsmanager_secret.gcp_credentials.arn
}

output "aws_secret_name" {
  description = "Name of AWS Secrets Manager secret containing GCP credentials"
  value       = aws_secretsmanager_secret.gcp_credentials.name
}
