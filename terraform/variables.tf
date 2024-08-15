# CloudMart Infrastructure Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# EKS Configuration
variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 3
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 6
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

# BigQuery Configuration
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

# Observability Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}
