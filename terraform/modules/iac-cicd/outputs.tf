# Outputs for IaC CI/CD Pipeline

output "iac_pipeline_name" {
  description = "Name of the IaC CodePipeline"
  value       = aws_codepipeline.iac_pipeline.name
}

output "iac_pipeline_arn" {
  description = "ARN of the IaC CodePipeline"
  value       = aws_codepipeline.iac_pipeline.arn
}

output "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_locks_table" {
  description = "DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "iac_artifacts_bucket" {
  description = "S3 bucket for IaC pipeline artifacts"
  value       = aws_s3_bucket.iac_pipeline_artifacts.bucket
}

output "notification_topic_arn" {
  description = "SNS topic ARN for notifications"
  value       = aws_sns_topic.iac_notifications.arn
}

output "codebuild_projects" {
  description = "CodeBuild project names for IaC pipeline"
  value = {
    validate = aws_codebuild_project.iac_validate.name
    plan     = aws_codebuild_project.iac_plan.name
    apply    = aws_codebuild_project.iac_apply.name
    notify   = aws_codebuild_project.iac_notify.name
  }
}
