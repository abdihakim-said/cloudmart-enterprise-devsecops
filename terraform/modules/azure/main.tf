# Azure Module - Text Analytics for Sentiment Analysis
# Multi-cloud integration with production best practices

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Resource Group for CloudMart Azure resources
resource "azurerm_resource_group" "cloudmart" {
  name     = "cloudmart-${var.environment}-rg"
  location = var.azure_location

  tags = merge(var.tags, {
    Name        = "CloudMart Resource Group"
    Environment = var.environment
    Purpose     = "text-analytics"
  })
}

# Cognitive Services Account for Text Analytics
resource "azurerm_cognitive_account" "text_analytics" {
  name                = "cloudmart-text-analytics-${var.environment}"
  location            = azurerm_resource_group.cloudmart.location
  resource_group_name = azurerm_resource_group.cloudmart.name
  kind                = "TextAnalytics"
  sku_name            = var.text_analytics_sku

  # checkov:skip=CKV_AZURE_134:Public access required for application integration
  public_network_access_enabled = true
  
  # checkov:skip=CKV_AZURE_236:Local auth required for API key authentication
  local_auth_enabled = true
  
  # Add managed identity for future security improvements
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Name        = "CloudMart Text Analytics"
    Environment = var.environment
    Purpose     = "sentiment-analysis"
    Service     = "cognitive-services"
  })
}

# Store Azure credentials in AWS Secrets Manager for secure access
# KMS key for secrets encryption
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Azure secrets encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/cloudmart-azure-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_secretsmanager_secret" "azure_text_analytics" {
  name        = "cloudmart/${var.environment}/azure/text-analytics"
  description = "Azure Text Analytics credentials for CloudMart ${var.environment}"
  
  # Add KMS encryption
  kms_key_id = aws_kms_key.secrets.arn

  tags = merge(var.tags, {
    Name        = "Azure Text Analytics Credentials"
    Environment = var.environment
    Type        = "secret"
  })
}

resource "aws_secretsmanager_secret_version" "azure_text_analytics" {
  secret_id = aws_secretsmanager_secret.azure_text_analytics.id
  secret_string = jsonencode({
    endpoint = azurerm_cognitive_account.text_analytics.endpoint
    key      = azurerm_cognitive_account.text_analytics.primary_access_key
    region   = var.azure_location
  })
}

# IAM policy for Lambda to access Azure credentials
resource "aws_iam_policy" "azure_secrets_access" {
  name        = "cloudmart-azure-secrets-access-${var.environment}"
  description = "Allow Lambda functions to access Azure Text Analytics credentials"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.azure_text_analytics.arn
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "Azure Secrets Access Policy"
    Environment = var.environment
    Type        = "iam-policy"
  })
}
