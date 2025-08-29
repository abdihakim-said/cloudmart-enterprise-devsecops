# DynamoDB Module - Production Best Practices
# Exact table structure aligned with your application code

# Products Table - matches 'cloudmart-products' from productService.js
resource "aws_dynamodb_table" "cloudmart_products" {
  name           = "cloudmart-products"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Production Best Practices
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = var.enable_encryption
  }

  deletion_protection_enabled = var.environment == "production" ? true : false

  tags = merge(var.tags, {
    Name        = "CloudMart Products Table"
    Type        = "dynamodb-table"
    Environment = var.environment
    Purpose     = "product-catalog"
  })

  lifecycle {
    prevent_destroy = true
  }
}

# Orders Table - matches 'cloudmart-orders' from orderService.js
resource "aws_dynamodb_table" "cloudmart_orders" {
  name           = "cloudmart-orders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  
  # Stream for BigQuery integration - exact configuration from your setup
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Production Best Practices
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = var.enable_encryption
  }

  deletion_protection_enabled = var.environment == "production" ? true : false

  tags = merge(var.tags, {
    Name        = "CloudMart Orders Table"
    Type        = "dynamodb-table"
    Environment = var.environment
    Purpose     = "order-management"
  })

  lifecycle {
    prevent_destroy = true
  }
}

# Tickets Table - matches 'cloudmart-tickets' from ticketService.js
resource "aws_dynamodb_table" "cloudmart_tickets" {
  name           = "cloudmart-tickets"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Production Best Practices
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = var.enable_encryption
  }

  deletion_protection_enabled = var.environment == "production" ? true : false

  tags = merge(var.tags, {
    Name        = "CloudMart Tickets Table"
    Type        = "dynamodb-table"
    Environment = var.environment
    Purpose     = "support-tickets"
  })

  lifecycle {
    prevent_destroy = true
  }
}
