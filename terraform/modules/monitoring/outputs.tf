# Monitoring Module Outputs

output "log_group_names" {
  description = "Names of CloudWatch log groups"
  value = {
    eks_cluster   = aws_cloudwatch_log_group.eks_cluster.name
    application   = aws_cloudwatch_log_group.application.name
    lambda        = aws_cloudwatch_log_group.lambda.name
  }
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "Names of CloudWatch alarms"
  value = {
    high_cpu         = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
    high_memory      = aws_cloudwatch_metric_alarm.high_memory.alarm_name
    alb_response_time = aws_cloudwatch_metric_alarm.alb_response_time.alarm_name
    dynamodb_throttles = aws_cloudwatch_metric_alarm.dynamodb_throttles.alarm_name
  }
}

output "xray_sampling_rule_name" {
  description = "Name of the X-Ray sampling rule"
  value       = aws_xray_sampling_rule.main.rule_name
}

output "synthetics_canary_name" {
  description = "Name of the Synthetics canary"
  value       = var.enable_synthetics ? aws_synthetics_canary.uptime_check[0].name : null
}
