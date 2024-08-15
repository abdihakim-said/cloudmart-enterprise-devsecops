# Lambda Module - Serverless Functions

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-lambda-role"
  })
}

# IAM Policy for Lambda functions
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:GetSecretValue",
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.products_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.orders_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.tickets_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.orders_table_name}/stream/*",
          "arn:aws:logs:*:*:*",
          "arn:aws:secretsmanager:*:*:secret:*",
          "arn:aws:bedrock:*:*:*"
        ]
      }
    ]
  })
}

# Attach basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda function for listing products
resource "aws_lambda_function" "list_products" {
  filename         = data.archive_file.list_products_zip.output_path
  function_name    = "${var.project_name}-list-products"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.list_products_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      PRODUCTS_TABLE = var.products_table_name
      REGION         = data.aws_region.current.name
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-list-products"
  })
}

# Lambda function for DynamoDB to BigQuery data pipeline
resource "aws_lambda_function" "dynamodb_to_bigquery" {
  filename         = data.archive_file.dynamodb_to_bigquery_zip.output_path
  function_name    = "${var.project_name}-dynamodb-to-bigquery"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.dynamodb_to_bigquery_zip.output_base64sha256
  timeout          = 300

  environment {
    variables = {
      GOOGLE_CLOUD_PROJECT_ID        = var.google_project_id
      BIGQUERY_DATASET_ID            = var.bigquery_dataset
      BIGQUERY_TABLE_ID              = var.bigquery_table
      GOOGLE_APPLICATION_CREDENTIALS = "/var/task/google_credentials.json"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-dynamodb-to-bigquery"
  })
}

# Lambda function for AI customer support
resource "aws_lambda_function" "ai_support" {
  filename         = data.archive_file.ai_support_zip.output_path
  function_name    = "${var.project_name}-ai-support"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  source_code_hash = data.archive_file.ai_support_zip.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      TICKETS_TABLE = var.tickets_table_name
      REGION        = data.aws_region.current.name
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ai-support"
  })
}

# Lambda event source mapping for DynamoDB stream
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = var.orders_stream_arn
  function_name     = aws_lambda_function.dynamodb_to_bigquery.arn
  starting_position = "LATEST"
  batch_size        = 10

  depends_on = [aws_iam_role_policy.lambda_policy]
}

# Lambda permissions for API Gateway (if needed)
resource "aws_lambda_permission" "allow_api_gateway_list_products" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_api_gateway_ai_support" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_support.function_name
  principal     = "apigateway.amazonaws.com"
}

# Lambda permission for Bedrock
resource "aws_lambda_permission" "allow_bedrock" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "bedrock.amazonaws.com"
}

# Create Lambda deployment packages
data "archive_file" "list_products_zip" {
  type        = "zip"
  output_path = "${path.module}/list_products.zip"
  source {
    content = templatefile("${path.module}/lambda_functions/list_products.js", {
      products_table = var.products_table_name
    })
    filename = "index.js"
  }
}

data "archive_file" "dynamodb_to_bigquery_zip" {
  type        = "zip"
  output_path = "${path.module}/dynamodb_to_bigquery.zip"
  source {
    content = templatefile("${path.module}/lambda_functions/dynamodb_to_bigquery.js", {
      google_project_id = var.google_project_id
      bigquery_dataset  = var.bigquery_dataset
      bigquery_table    = var.bigquery_table
    })
    filename = "index.js"
  }
}

data "archive_file" "ai_support_zip" {
  type        = "zip"
  output_path = "${path.module}/ai_support.zip"
  source {
    content = templatefile("${path.module}/lambda_functions/ai_support.js", {
      tickets_table = var.tickets_table_name
    })
    filename = "index.js"
  }
}

# Data sources
data "aws_region" "current" {}
