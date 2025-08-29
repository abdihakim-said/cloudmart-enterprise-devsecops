# Monitoring Module - Production-Ready Observability Stack
# Creates CloudWatch logs, metrics, alarms, and dashboards

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-eks-cluster-logs"
    Type = "log-group"
    Purpose = "eks-cluster"
  })
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-application-logs"
    Type = "log-group"
    Purpose = "application"
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-lambda-logs"
    Type = "log-group"
    Purpose = "lambda"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_request_count", "ClusterName", var.cluster_name],
            [".", "cluster_request_total", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EKS Cluster Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.project_name}-${var.environment}-alb"],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Application Load Balancer Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "${var.project_name}-products"],
            [".", "ConsumedWriteCapacityUnits", ".", "."],
            [".", "ThrottledRequests", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "DynamoDB Metrics"
          period  = 300
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = "${var.project_name}-${var.environment}-eks-nodes"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-high-cpu-alarm"
    Type = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-${var.environment}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors memory utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-high-memory-alarm"
    Type = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB response time"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = "${var.project_name}-${var.environment}-alb"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-response-time-alarm"
    Type = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.project_name}-${var.environment}-dynamodb-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB throttles"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TableName = "${var.project_name}-products"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-dynamodb-throttles-alarm"
    Type = "cloudwatch-alarm"
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
    Type = "sns-topic"
  })
}

# SNS Topic Subscription (email)
resource "aws_sns_topic_subscription" "email_alerts" {
  count = var.alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Insights Queries
resource "aws_cloudwatch_query_definition" "error_logs" {
  name = "${var.project_name}-${var.environment}-error-logs"

  log_group_names = [
    aws_cloudwatch_log_group.application.name,
    aws_cloudwatch_log_group.lambda.name
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
EOF
}

resource "aws_cloudwatch_query_definition" "performance_analysis" {
  name = "${var.project_name}-${var.environment}-performance-analysis"

  log_group_names = [
    aws_cloudwatch_log_group.application.name
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /response_time/
| stats avg(response_time) by bin(5m)
| sort @timestamp desc
EOF
}

# Container Insights (if enabled)
resource "aws_eks_addon" "container_insights" {
  count = var.enable_container_insights ? 1 : 0

  cluster_name = var.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-container-insights"
    Type = "eks-addon"
  })
}

# X-Ray Tracing (for distributed tracing)
resource "aws_xray_sampling_rule" "main" {
  rule_name      = "${var.project_name}-${var.environment}-sampling"
  priority       = 9000
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.1
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-xray-sampling"
    Type = "xray-sampling-rule"
  })
}

# CloudWatch Synthetics (for uptime monitoring)
resource "aws_synthetics_canary" "uptime_check" {
  count = var.enable_synthetics ? 1 : 0

  name                 = "${var.project_name}-${var.environment}-uptime-check"
  artifact_s3_location = "s3://${aws_s3_bucket.synthetics_artifacts[0].bucket}/canary-artifacts"
  execution_role_arn   = aws_iam_role.synthetics[0].arn
  handler              = "pageLoadBlueprint.handler"
  zip_file             = "synthetics-canary.zip"
  runtime_version      = "syn-nodejs-puppeteer-6.2"

  schedule {
    expression = "rate(5 minutes)"
  }

  run_config {
    timeout_in_seconds = 60
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-uptime-check"
    Type = "synthetics-canary"
  })
}

# S3 Bucket for Synthetics Artifacts
resource "aws_s3_bucket" "synthetics_artifacts" {
  count = var.enable_synthetics ? 1 : 0

  bucket = "${var.project_name}-${var.environment}-synthetics-artifacts-${random_string.bucket_suffix.result}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-synthetics-artifacts"
    Type = "s3-bucket"
  })
}

resource "aws_s3_bucket_versioning" "synthetics_artifacts" {
  count = var.enable_synthetics ? 1 : 0

  bucket = aws_s3_bucket.synthetics_artifacts[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "synthetics_artifacts" {
  count = var.enable_synthetics ? 1 : 0

  bucket = aws_s3_bucket.synthetics_artifacts[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM Role for Synthetics
resource "aws_iam_role" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  name = "${var.project_name}-${var.environment}-synthetics-role"

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
    Name = "${var.project_name}-${var.environment}-synthetics-role"
    Type = "iam-role"
  })
}

resource "aws_iam_role_policy_attachment" "synthetics" {
  count = var.enable_synthetics ? 1 : 0

  role       = aws_iam_role.synthetics[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchSyntheticsExecutionRolePolicy"
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}
