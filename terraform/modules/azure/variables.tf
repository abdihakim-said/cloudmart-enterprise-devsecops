# Azure Module Variables

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "azure_location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3",
      "Central US", "North Central US", "South Central US", "West Central US",
      "Canada Central", "Canada East", "Brazil South", "North Europe", "West Europe",
      "UK South", "UK West", "France Central", "Germany West Central",
      "Switzerland North", "Norway East", "UAE North", "South Africa North",
      "Australia East", "Australia Southeast", "Central India", "South India",
      "West India", "Japan East", "Japan West", "Korea Central", "Korea South",
      "Southeast Asia", "East Asia"
    ], var.azure_location)
    error_message = "Azure location must be a valid Azure region."
  }
}

variable "text_analytics_sku" {
  description = "SKU for Azure Text Analytics service"
  type        = string
  default     = "S"
  
  validation {
    condition = contains(["F0", "S"], var.text_analytics_sku)
    error_message = "Text Analytics SKU must be F0 (free) or S (standard)."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
