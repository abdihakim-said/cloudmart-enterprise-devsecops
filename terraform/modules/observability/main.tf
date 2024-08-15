# Observability Module - Prometheus, Grafana, EFK Stack, Jaeger

# S3 Bucket for observability data storage
resource "aws_s3_bucket" "observability_data" {
  bucket = "${var.project_name}-observability-data-${random_string.bucket_suffix.result}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-observability-data"
  })
}

resource "aws_s3_bucket_versioning" "observability_versioning" {
  bucket = aws_s3_bucket.observability_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "observability_encryption" {
  bucket = aws_s3_bucket.observability_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "observability_lifecycle" {
  bucket = aws_s3_bucket.observability_data.id

  rule {
    id     = "observability_data_lifecycle"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = var.retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-application-logs"
  })
}

resource "aws_cloudwatch_log_group" "audit_logs" {
  name              = "/aws/eks/${var.cluster_name}/audit"
  retention_in_days = 90

  tags = merge(var.tags, {
    Name = "${var.project_name}-audit-logs"
  })
}

resource "aws_cloudwatch_log_group" "prometheus_logs" {
  name              = "/aws/eks/${var.cluster_name}/prometheus"
  retention_in_days = var.retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-prometheus-logs"
  })
}

resource "aws_cloudwatch_log_group" "grafana_logs" {
  name              = "/aws/eks/${var.cluster_name}/grafana"
  retention_in_days = var.retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-grafana-logs"
  })
}

# IAM Role for observability services
resource "aws_iam_role" "observability_role" {
  name = "${var.project_name}-observability-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.cluster_endpoint, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(var.cluster_endpoint, "https://", "")}:sub" = "system:serviceaccount:monitoring:prometheus"
            "${replace(var.cluster_endpoint, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-observability-role"
  })
}

# IAM Policy for observability services
resource "aws_iam_role_policy" "observability_policy" {
  name = "${var.project_name}-observability-policy"
  role = aws_iam_role.observability_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "tag:GetResources"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.observability_data.arn,
          "${aws_s3_bucket.observability_data.arn}/*"
        ]
      }
    ]
  })
}

# Security Group for observability services
resource "aws_security_group" "observability" {
  name_prefix = "${var.project_name}-observability-"
  vpc_id      = var.vpc_id

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Elasticsearch
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Kibana
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Jaeger
  ingress {
    from_port   = 16686
    to_port     = 16686
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Node exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-observability-sg"
  })
}

# Application Load Balancer for observability services
resource "aws_lb" "observability" {
  name               = "${var.project_name}-observability-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.observability.id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-observability-alb"
  })
}

# Target Groups for observability services
resource "aws_lb_target_group" "prometheus" {
  name     = "${var.project_name}-prometheus-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/-/healthy"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-prometheus-tg"
  })
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.project_name}-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-grafana-tg"
  })
}

# ALB Listeners
resource "aws_lb_listener" "observability" {
  load_balancer_arn = aws_lb.observability.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "CloudMart Observability Stack"
      status_code  = "200"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-observability-listener"
  })
}

resource "aws_lb_listener_rule" "prometheus" {
  listener_arn = aws_lb_listener.observability.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }

  condition {
    path_pattern {
      values = ["/prometheus*"]
    }
  }
}

resource "aws_lb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.observability.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  condition {
    path_pattern {
      values = ["/grafana*"]
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
