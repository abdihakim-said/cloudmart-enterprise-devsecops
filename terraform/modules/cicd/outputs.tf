# Outputs for DevSecOps CI/CD Pipeline

output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.cloudmart_pipeline.name
}

output "pipeline_arn" {
  description = "ARN of the CodePipeline"
  value       = aws_codepipeline.cloudmart_pipeline.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.cloudmart.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.cloudmart.name
}

output "artifacts_bucket" {
  description = "S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.codepipeline_artifacts.bucket
}

output "codebuild_projects" {
  description = "CodeBuild project names"
  value = {
    security_scan = aws_codebuild_project.security_scan.name
    build_test    = aws_codebuild_project.build_and_test.name
    deploy        = aws_codebuild_project.deploy.name
  }
}

output "github_webhook_url" {
  description = "GitHub webhook URL for manual setup"
  value       = "https://codepipeline.${var.aws_region}.amazonaws.com/webhooks?Action=StartPipelineExecution&PipelineName=${aws_codepipeline.cloudmart_pipeline.name}"
}
