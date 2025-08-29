# CloudMart Infrastructure

This directory contains the Terraform infrastructure code for the CloudMart multi-cloud platform.

## Infrastructure Components

- **AWS**: EKS cluster, DynamoDB tables, Lambda functions
- **Azure**: AI Language services for sentiment analysis  
- **GCP**: BigQuery for cross-cloud analytics
- **CI/CD**: DevSecOps pipelines for infrastructure deployment

## Security Features

- Comprehensive security scanning with Checkov and tfsec
- Encrypted state management with S3 backend
- Manual approval gates for production changes
- Compliance reporting and audit logging

## Usage

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes (with approval)
terraform apply
```

## Pipeline Trigger Test

This file triggers the DevSecOps Infrastructure Pipeline for validation and security scanning.
# Pipeline trigger test - Fri 29 Aug 2025 23:58:06 EAT
