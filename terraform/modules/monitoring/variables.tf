# Monitoring Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for EKS"
  type        = bool
  default     = true
}

variable "enable_synthetics" {
  description = "Enable CloudWatch Synthetics for uptime monitoring"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
