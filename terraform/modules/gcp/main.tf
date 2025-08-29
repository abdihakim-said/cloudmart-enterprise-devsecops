# Google Cloud Module - BigQuery for Analytics
# Multi-cloud integration with production best practices

# BigQuery Dataset
resource "google_bigquery_dataset" "cloudmart" {
  dataset_id                  = var.bigquery_dataset
  friendly_name              = "CloudMart Analytics Dataset"
  description                = "Dataset for CloudMart order analytics and business intelligence"
  location                   = var.bigquery_location
  default_table_expiration_ms = 3600000 # 1 hour default expiration

  labels = {
    project     = "cloudmart"
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "analytics"
  }
}

# BigQuery Table for Orders
resource "google_bigquery_table" "orders" {
  dataset_id = google_bigquery_dataset.cloudmart.dataset_id
  table_id   = var.bigquery_table

  description = "CloudMart orders data from DynamoDB stream"

  labels = {
    project     = "cloudmart"
    environment = var.environment
    data_source = "dynamodb"
  }

  schema = jsonencode([
    {
      name = "id"
      type = "STRING"
      mode = "REQUIRED"
      description = "Order ID from DynamoDB"
    },
    {
      name = "userEmail"
      type = "STRING"
      mode = "NULLABLE"
      description = "Customer email address"
    },
    {
      name = "status"
      type = "STRING"
      mode = "NULLABLE"
      description = "Order status"
    },
    {
      name = "createdAt"
      type = "TIMESTAMP"
      mode = "NULLABLE"
      description = "Order creation timestamp"
    },
    {
      name = "updatedAt"
      type = "TIMESTAMP"
      mode = "NULLABLE"
      description = "Last update timestamp"
    },
    {
      name = "eventType"
      type = "STRING"
      mode = "NULLABLE"
      description = "DynamoDB event type (INSERT/MODIFY)"
    },
    {
      name = "totalAmount"
      type = "FLOAT"
      mode = "NULLABLE"
      description = "Order total amount"
    },
    {
      name = "items"
      type = "STRING"
      mode = "NULLABLE"
      description = "Order items as JSON string"
    }
  ])

  time_partitioning {
    type  = "DAY"
    field = "createdAt"
  }

  clustering = ["status", "userEmail"]
}

# Service Account for Lambda to access BigQuery
resource "google_service_account" "lambda_bigquery" {
  account_id   = "cloudmart-lambda-bigquery"
  display_name = "CloudMart Lambda BigQuery Service Account"
  description  = "Service account for AWS Lambda to write to BigQuery"
}

# IAM binding for BigQuery Data Editor role
resource "google_project_iam_member" "lambda_bigquery_editor" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.lambda_bigquery.email}"
}

# IAM binding for BigQuery Job User role
resource "google_project_iam_member" "lambda_bigquery_job_user" {
  project = var.gcp_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.lambda_bigquery.email}"
}

# Service Account Key for Lambda
resource "google_service_account_key" "lambda_bigquery_key" {
  service_account_id = google_service_account.lambda_bigquery.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Store the service account key in AWS Secrets Manager
resource "aws_secretsmanager_secret" "gcp_credentials" {
  name        = "cloudmart/${var.environment}/gcp/bigquery-credentials"
  description = "GCP service account credentials for BigQuery access"

  tags = merge(var.tags, {
    Name        = "GCP BigQuery Credentials"
    Environment = var.environment
    Type        = "secret"
    Purpose     = "bigquery-access"
  })
}

resource "aws_secretsmanager_secret_version" "gcp_credentials" {
  secret_id     = aws_secretsmanager_secret.gcp_credentials.id
  secret_string = base64decode(google_service_account_key.lambda_bigquery_key.private_key)
}
