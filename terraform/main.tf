# CloudMart Production Infrastructure
# Complete multi-cloud architecture with production best practices

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Production state management - Enable for CI/CD
  backend "s3" {
    bucket         = "cloudmart-terraform-state-2wheu9hm"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "cloudmart-terraform-locks"
  }
}

# Configure the AWS Provider

# Configure the Azure Provider
provider "azurerm" {
  features {}
  
  # Use environment variables (ARM_*)
  use_cli                    = false
  use_msi                    = false
  use_oidc                   = false
  skip_provider_registration = true
}

# Configure the Google Cloud Provider  
provider "google" {
  project = var.google_project_id
  region  = var.gcp_region
  
  # Use GOOGLE_CREDENTIALS environment variable
}


# Local values for common configurations
locals {
  common_tags = merge(var.tags, {
    Project     = "CloudMart"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# 1. DynamoDB Module - Exact table names and configuration from your setup
module "dynamodb" {
  source = "./modules/dynamodb"
  
  environment                   = var.environment
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
  enable_encryption            = var.enable_encryption
  
  tags = local.common_tags
}

# 2. Azure Module - Text Analytics for sentiment analysis
module "azure" {
  source = "./modules/azure"
  
  environment         = var.environment
  azure_location      = var.azure_location
  text_analytics_sku  = var.text_analytics_sku
  
  # Pass Azure credentials from environment variables
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  azure_subscription_id = var.azure_subscription_id
  azure_tenant_id       = var.azure_tenant_id
  
  tags = local.common_tags
}

# 3. GCP Module - BigQuery for analytics
module "gcp" {
  source = "./modules/gcp"
  
  gcp_project_id      = var.google_project_id
  gcp_region          = var.gcp_region
  bigquery_location   = var.bigquery_location
  bigquery_dataset    = var.bigquery_dataset
  bigquery_table      = var.bigquery_table
  environment         = var.environment
  
  tags = local.common_tags
}

# 3.5. ACM Certificate Module
module "acm" {
  source = "./modules/acm"
  
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  route53_zone_id          = var.route53_zone_id
}

# 3.6. WAF Module
module "waf" {
  source = "./modules/waf"
  
  environment   = var.environment
  project_name  = var.project_name
}

# 4. Lambda Module - Functions aligned with your exact configuration
module "lambda" {
  source = "./modules/lambda"
  
  environment    = var.environment
  lambda_runtime = var.lambda_runtime
  
  # DynamoDB dependencies - exact table references
  products_table_name = module.dynamodb.products_table_name
  products_table_arn  = module.dynamodb.products_table_arn
  orders_table_name   = module.dynamodb.orders_table_name
  orders_table_arn    = module.dynamodb.orders_table_arn
  orders_stream_arn   = module.dynamodb.orders_stream_arn
  tickets_table_name  = module.dynamodb.tickets_table_name
  tickets_table_arn   = module.dynamodb.tickets_table_arn
  
  # BigQuery configuration - exact values from your setup
  google_project_id = var.google_project_id
  bigquery_dataset  = var.bigquery_dataset
  bigquery_table    = var.bigquery_table
  
  # Azure integration
  azure_secret_arn = module.azure.aws_secret_arn
  
  # GCP integration
  gcp_secret_arn = module.gcp.aws_secret_arn
  
  tags = local.common_tags
}

# 5. EKS Module - Kubernetes cluster for application deployment
module "eks" {
  source = "./modules/eks"
  
  tags = local.common_tags
}

# 6. CI/CD Module - DevSecOps pipeline for application deployment
module "cicd" {
  source = "./modules/cicd"
  
  aws_region    = var.aws_region
  github_owner  = var.github_owner
  github_repo   = var.github_repo
  environment   = var.environment
  project_name  = "cloudmart"
}

# 7. IaC CI/CD Module - DevSecOps pipeline for infrastructure deployment
module "iac_cicd" {
  source = "./modules/iac-cicd"
  
  aws_region    = var.aws_region
  github_owner  = var.github_owner
  github_repo   = var.github_repo
  environment   = var.environment
}
