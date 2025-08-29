# Azure Module Outputs

output "text_analytics_endpoint" {
  description = "Azure Text Analytics endpoint URL"
  value       = azurerm_cognitive_account.text_analytics.endpoint
  sensitive   = true
}

output "text_analytics_key" {
  description = "Azure Text Analytics primary access key"
  value       = azurerm_cognitive_account.text_analytics.primary_access_key
  sensitive   = true
}

output "text_analytics_name" {
  description = "Name of the Azure Text Analytics service"
  value       = azurerm_cognitive_account.text_analytics.name
}

output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.cloudmart.name
}

output "azure_location" {
  description = "Azure location where resources are deployed"
  value       = azurerm_resource_group.cloudmart.location
}

output "aws_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing Azure credentials"
  value       = aws_secretsmanager_secret.azure_text_analytics.arn
}

output "aws_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing Azure credentials"
  value       = aws_secretsmanager_secret.azure_text_analytics.name
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy for accessing Azure credentials"
  value       = aws_iam_policy.azure_secrets_access.arn
}
