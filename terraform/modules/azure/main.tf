# Azure Module - Text Analytics for Sentiment Analysis
# Multi-cloud integration with production best practices

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

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

  # Enable public network access (can be restricted in production)
  public_network_access_enabled = true

  tags = merge(var.tags, {
    Name        = "CloudMart Text Analytics"
    Environment = var.environment
    Purpose     = "sentiment-analysis"
    Service     = "cognitive-services"
  })
}

# Store Azure credentials in AWS Secrets Manager for secure access
resource "aws_secretsmanager_secret" "azure_text_analytics" {
  name        = "cloudmart/${var.environment}/azure/text-analytics"
  description = "Azure Text Analytics credentials for CloudMart ${var.environment}"

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
