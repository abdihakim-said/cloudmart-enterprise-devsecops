# ECR Module Outputs

output "repository_urls" {
  description = "URLs of the ECR repositories"
  value       = { for i, repo in aws_ecr_repository.repositories : var.repositories[i] => repo.repository_url }
}

output "repository_arns" {
  description = "ARNs of the ECR repositories"
  value       = { for i, repo in aws_ecr_repository.repositories : var.repositories[i] => repo.arn }
}

output "repository_names" {
  description = "Names of the ECR repositories"
  value       = aws_ecr_repository.repositories[*].name
}
