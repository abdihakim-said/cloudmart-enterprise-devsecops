# Variables for IaC CI/CD Pipeline

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "github_owner" {
  description = "GitHub repository owner/organization"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Email for pipeline notifications"
  type        = string
  default     = "admin@cloudmart.com"
}
