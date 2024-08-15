# Observability Module Outputs

output "observability_bucket" {
  description = "S3 bucket for observability data"
  value       = aws_s3_bucket.observability_data.bucket
}

output "observability_bucket_arn" {
  description = "ARN of the observability S3 bucket"
  value       = aws_s3_bucket.observability_data.arn
}

output "prometheus_endpoint" {
  description = "Prometheus endpoint URL"
  value       = "http://${aws_lb.observability.dns_name}/prometheus"
}

output "grafana_endpoint" {
  description = "Grafana endpoint URL"
  value       = "http://${aws_lb.observability.dns_name}/grafana"
}

output "observability_security_group_id" {
  description = "Security group ID for observability services"
  value       = aws_security_group.observability.id
}

output "observability_role_arn" {
  description = "IAM role ARN for observability services"
  value       = aws_iam_role.observability_role.arn
}

output "application_log_group_name" {
  description = "CloudWatch log group name for application logs"
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "prometheus_log_group_name" {
  description = "CloudWatch log group name for Prometheus logs"
  value       = aws_cloudwatch_log_group.prometheus_logs.name
}

output "grafana_log_group_name" {
  description = "CloudWatch log group name for Grafana logs"
  value       = aws_cloudwatch_log_group.grafana_logs.name
}
