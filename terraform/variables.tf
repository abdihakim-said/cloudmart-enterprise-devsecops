# CloudMart Infrastructure Variables - Complete Multi-Cloud

variable "aws_region" {
  description = "AWS region for resources deployment"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in format like 'us-east-1'."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
  
  validation {
    condition = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

# Azure Configuration
variable "azure_location" {
  description = "Azure region for Text Analytics service"
  type        = string
  default     = "East US"
}

variable "text_analytics_sku" {
  description = "SKU for Azure Text Analytics service (F0=free, S=standard)"
  type        = string
  default     = "S"
  
  validation {
    condition = contains(["F0", "S"], var.text_analytics_sku)
    error_message = "Text Analytics SKU must be F0 (free) or S (standard)."
  }
}

# GCP Configuration
variable "gcp_region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "bigquery_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
  
  validation {
    condition = contains(["US", "EU", "asia-northeast1", "us-central1", "us-east1", "us-west1"], var.bigquery_location)
    error_message = "BigQuery location must be a valid location."
  }
}

# BigQuery Configuration - Exact values from your config
variable "google_project_id" {
  description = "Google Cloud Project ID for BigQuery"
  type        = string
  default     = "optical-aviary-446420-i1"
}

variable "bigquery_dataset" {
  description = "BigQuery dataset name"
  type        = string
  default     = "cloudmart"
}

variable "bigquery_table" {
  description = "BigQuery table name"
  type        = string
  default     = "cloudmart-orders"
}

# Additional production configurations
variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB tables"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable encryption at rest for DynamoDB tables"
  type        = bool
  default     = true
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "nodejs20.x"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "CloudMart"
    Owner       = "DevOps-Team"
    CostCenter  = "Engineering"
  }
}
# GitHub Configuration for CI/CD
variable "github_owner" {
  description = "GitHub repository owner/organization"
  type        = string
  default     = "abdihakim-said"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "cloudmart-enterprise-devsecops"
}
