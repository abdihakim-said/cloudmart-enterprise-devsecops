# CloudMart Infrastructure - Main Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "CloudMart"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "DevOps-Team"
    }
  }
}

# Local values for common configurations
locals {
  project_name = "cloudmart"
  common_tags = {
    Project     = "CloudMart"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  project_name        = local.project_name
  environment         = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
  tags = local.common_tags
}

# Database Module (DynamoDB)
module "database" {
  source = "./modules/database"
  
  project_name = local.project_name
  environment  = var.environment
  
  tags = local.common_tags
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"
  
  project_name = local.project_name
  environment  = var.environment
  
  # Dependencies from other modules
  products_table_name = module.database.products_table_name
  orders_table_name   = module.database.orders_table_name
  tickets_table_name  = module.database.tickets_table_name
  orders_stream_arn   = module.database.orders_stream_arn
  
  # BigQuery configuration
  google_project_id = var.google_project_id
  bigquery_dataset  = var.bigquery_dataset
  bigquery_table    = var.bigquery_table
  
  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  project_name = local.project_name
  environment  = var.environment
  
  # Networking dependencies
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  public_subnet_ids   = module.networking.public_subnet_ids
  
  # EKS configuration
  cluster_version     = var.eks_cluster_version
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_max_size       = var.eks_node_max_size
  node_min_size       = var.eks_node_min_size
  
  tags = local.common_tags
}

# Observability Module
module "observability" {
  source = "./modules/observability"
  
  project_name = local.project_name
  environment  = var.environment
  
  # Dependencies from other modules
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  cluster_name       = module.eks.cluster_name
  cluster_endpoint   = module.eks.cluster_endpoint
  
  # Observability configuration
  retention_days = var.log_retention_days
  
  tags = local.common_tags
}

# ECR Module for container images
module "ecr" {
  source = "./modules/ecr"
  
  project_name = local.project_name
  environment  = var.environment
  
  repositories = [
    "cloudmart-frontend",
    "cloudmart-backend"
  ]
  
  tags = local.common_tags
}
