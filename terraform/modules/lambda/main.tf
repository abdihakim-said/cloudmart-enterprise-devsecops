# Lambda Module - Production Best Practices
# Exact configuration aligned with your setup

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "cloudmart-lambda-role-${var.environment}"

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
    Name        = "CloudMart Lambda Role"
    Type        = "iam-role"
    Environment = var.environment
  })
}

# IAM Policy for Lambda functions - exact permissions from your config + SQS for DLQ + GCP secrets
resource "aws_iam_role_policy" "lambda_policy" {
  name = "cloudmart-lambda-policy-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "bedrock:InvokeModel",
          "sqs:SendMessage",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.products_table_arn,
          var.orders_table_arn,
          "${var.orders_table_arn}/stream/*",
          var.tickets_table_arn,
          "arn:aws:logs:*:*:*",
          "arn:aws:bedrock:*:*:foundation-model/*",
          aws_sqs_queue.lambda_dlq.arn,
          var.azure_secret_arn,
          "arn:aws:secretsmanager:us-east-1:682881510910:secret:cloudmart/production/gcp/bigquery-credentials-*"
        ]
      }
    ]
  })
}

# CloudWatch Log Group for Lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = toset(["list-products", "dynamodb-to-bigquery"])
  
  name              = "/aws/lambda/cloudmart-${each.key}-${var.environment}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name        = "CloudMart ${title(replace(each.key, "-", " "))} Logs"
    Type        = "log-group"
    Environment = var.environment
  })
}

# Dead Letter Queue for Lambda functions - Production Best Practice
resource "aws_sqs_queue" "lambda_dlq" {
  name                      = "cloudmart-lambda-dlq-${var.environment}"
  message_retention_seconds = 1209600 # 14 days

  tags = merge(var.tags, {
    Name        = "CloudMart Lambda DLQ"
    Type        = "sqs-queue"
    Environment = var.environment
    Purpose     = "dead-letter-queue"
  })
}

# Create Lambda deployment package for list products
data "archive_file" "list_products_zip" {
  type        = "zip"
  output_path = "${path.module}/list_products.zip"
  source {
    content = <<EOF
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log('List Products Event:', JSON.stringify(event, null, 2));
    
    try {
        const params = {
            TableName: process.env.PRODUCTS_TABLE
        };
        
        const result = await dynamodb.scan(params).promise();
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization'
            },
            body: JSON.stringify({
                success: true,
                products: result.Items,
                count: result.Count
            })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                success: false,
                error: error.message
            })
        };
    }
};
EOF
    filename = "index.js"
  }
}

# Lambda function for listing products - exact configuration from your setup
resource "aws_lambda_function" "list_products" {
  filename         = data.archive_file.list_products_zip.output_path
  function_name    = "cloudmart-list-products-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = 30
  memory_size      = 256
  source_code_hash = data.archive_file.list_products_zip.output_base64sha256

  environment {
    variables = {
      PRODUCTS_TABLE = var.products_table_name
      ENVIRONMENT    = var.environment
    }
  }

  # Production Best Practices
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_cloudwatch_log_group.lambda_logs,
    aws_sqs_queue.lambda_dlq
  ]

  tags = merge(var.tags, {
    Name        = "CloudMart List Products Function"
    Type        = "lambda-function"
    Environment = var.environment
    Purpose     = "product-listing"
  })
}

# Create Lambda deployment package for DynamoDB to BigQuery
data "archive_file" "dynamodb_to_bigquery_zip" {
  type        = "zip"
  output_path = "${path.module}/dynamodb_to_bigquery.zip"
  source {
    content = <<EOF
const { BigQuery } = require('@google-cloud/bigquery');
const AWS = require('aws-sdk');

const secretsManager = new AWS.SecretsManager({ region: 'us-east-1' });

exports.handler = async (event) => {
    console.log('DynamoDB Stream Event:', JSON.stringify(event, null, 2));
    
    try {
        // Get GCP credentials from AWS Secrets Manager
        const secretResponse = await secretsManager.getSecretValue({
            SecretId: 'cloudmart/production/gcp/bigquery-credentials'
        }).promise();
        
        const gcpCredentials = JSON.parse(secretResponse.SecretString);
        
        // Initialize BigQuery client with credentials
        const bigquery = new BigQuery({
            projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
            credentials: gcpCredentials
        });
        
        const dataset = bigquery.dataset(process.env.BIGQUERY_DATASET_ID);
        const table = dataset.table(process.env.BIGQUERY_TABLE_ID);
        
        const rowsToInsert = [];
        
        // Process each record from DynamoDB stream
        for (const record of event.Records) {
            if (record.eventName === 'INSERT' || record.eventName === 'MODIFY') {
                const dynamoRecord = record.dynamodb.NewImage;
                
                // Transform DynamoDB record to BigQuery format
                const row = {
                    id: dynamoRecord.id?.S || '',
                    userEmail: dynamoRecord.userEmail?.S || '',
                    status: dynamoRecord.status?.S || '',
                    createdAt: dynamoRecord.createdAt?.S || new Date().toISOString(),
                    updatedAt: new Date().toISOString(),
                    eventType: record.eventName,
                    totalAmount: parseFloat(dynamoRecord.totalAmount?.N || dynamoRecord.total?.N || '0'),
                    items: JSON.stringify(dynamoRecord.items?.L || dynamoRecord.items?.S || [])
                };
                
                rowsToInsert.push(row);
            }
        }
        
        if (rowsToInsert.length > 0) {
            // Insert rows into BigQuery
            await table.insert(rowsToInsert);
            console.log('Successfully inserted ' + rowsToInsert.length + ' rows into BigQuery');
        }
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                success: true,
                processedRecords: rowsToInsert.length
            })
        };
        
    } catch (error) {
        console.error('Error processing DynamoDB stream:', error);
        throw error;
    }
};
EOF
    filename = "index.js"
  }
}

# Lambda function for DynamoDB to BigQuery - exact configuration from your setup
resource "aws_lambda_function" "dynamodb_to_bigquery" {
  filename         = data.archive_file.dynamodb_to_bigquery_zip.output_path
  function_name    = "cloudmart-dynamodb-to-bigquery-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  timeout          = 300
  memory_size      = 512
  source_code_hash = data.archive_file.dynamodb_to_bigquery_zip.output_base64sha256

  environment {
    variables = {
      GOOGLE_CLOUD_PROJECT_ID = var.google_project_id
      BIGQUERY_DATASET_ID     = var.bigquery_dataset
      BIGQUERY_TABLE_ID       = var.bigquery_table
      ENVIRONMENT             = var.environment
    }
  }

  # Production Best Practices
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy,
    aws_cloudwatch_log_group.lambda_logs,
    aws_sqs_queue.lambda_dlq
  ]

  tags = merge(var.tags, {
    Name        = "CloudMart DynamoDB to BigQuery Function"
    Type        = "lambda-function"
    Environment = var.environment
    Purpose     = "data-pipeline"
  })
}

# Lambda event source mapping for DynamoDB stream - exact configuration
resource "aws_lambda_event_source_mapping" "dynamodb_stream" {
  event_source_arn  = var.orders_stream_arn
  function_name     = aws_lambda_function.dynamodb_to_bigquery.arn
  starting_position = "LATEST"
  batch_size        = 10
  
  # Production Best Practices
  maximum_batching_window_in_seconds = 5
  parallelization_factor            = 2

  depends_on = [aws_iam_role_policy.lambda_policy]
}

# Lambda permission for Bedrock - exact configuration from your setup
resource "aws_lambda_permission" "allow_bedrock" {
  statement_id  = "AllowBedrockInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_products.function_name
  principal     = "bedrock.amazonaws.com"
}
