# IaC CI/CD Pipeline for Terraform
# 6-Stage Pipeline: Source → Validate → Plan → Approve → Apply → Notify

# S3 Bucket for IaC Pipeline artifacts
resource "aws_s3_bucket" "iac_pipeline_artifacts" {
  bucket = "cloudmart-iac-pipeline-artifacts-${random_string.iac_suffix.result}"
}

resource "aws_s3_bucket_versioning" "iac_pipeline_artifacts" {
  bucket = aws_s3_bucket.iac_pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "iac_pipeline_artifacts" {
  bucket = aws_s3_bucket.iac_pipeline_artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_string" "iac_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket for Terraform State Backend
resource "aws_s3_bucket" "terraform_state" {
  bucket = "cloudmart-terraform-state-${random_string.iac_suffix.result}"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "cloudmart-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}

# CodeBuild Projects for IaC Pipeline

# Stage 2: Validate & Security
resource "aws_codebuild_project" "iac_validate" {
  name         = "cloudmart-iac-validate"
  description  = "Terraform validation and security scanning"
  service_role = aws_iam_role.iac_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VAR_environment"
      value = var.environment
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-iac-validate.yml"
  }
}

# Stage 3: Plan
resource "aws_codebuild_project" "iac_plan" {
  name         = "cloudmart-iac-plan"
  description  = "Terraform plan generation with cost estimation"
  service_role = aws_iam_role.iac_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VAR_environment"
      value = var.environment
    }
    environment_variable {
      name  = "S3_BACKEND_BUCKET"
      value = aws_s3_bucket.terraform_state.bucket
    }
    environment_variable {
      name  = "DYNAMODB_TABLE"
      value = aws_dynamodb_table.terraform_locks.name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-iac-plan.yml"
  }
}

# Stage 5: Apply
resource "aws_codebuild_project" "iac_apply" {
  name         = "cloudmart-iac-apply"
  description  = "Terraform apply with state management"
  service_role = aws_iam_role.iac_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VAR_environment"
      value = var.environment
    }
    environment_variable {
      name  = "S3_BACKEND_BUCKET"
      value = aws_s3_bucket.terraform_state.bucket
    }
    environment_variable {
      name  = "DYNAMODB_TABLE"
      value = aws_dynamodb_table.terraform_locks.name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-iac-apply.yml"
  }
}

# Stage 6: Notify
resource "aws_codebuild_project" "iac_notify" {
  name         = "cloudmart-iac-notify"
  description  = "Post-deployment notifications and documentation"
  service_role = aws_iam_role.iac_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-iac-notify.yml"
  }
}

# SNS Topic for notifications
resource "aws_sns_topic" "iac_notifications" {
  name = "cloudmart-iac-notifications"
}

# IaC CodePipeline
resource "aws_codepipeline" "iac_pipeline" {
  name     = "cloudmart-iac-pipeline"
  role_arn = aws_iam_role.iac_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.iac_pipeline_artifacts.bucket
    type     = "S3"
  }

  # Stage 1: Source
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = "main"
        OAuthToken = data.aws_secretsmanager_secret_version.github_token.secret_string
      }
    }
  }

  # Stage 2: Validate & Security
  stage {
    name = "ValidateAndSecurity"

    action {
      name             = "ValidateAndSecurity"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["validate_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.iac_validate.name
      }
    }
  }

  # Stage 3: Plan
  stage {
    name = "Plan"

    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["validate_output"]
      output_artifacts = ["plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.iac_plan.name
      }
    }
  }

  # Stage 4: Manual Approval
  stage {
    name = "ManualApproval"

    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.iac_notifications.arn
        CustomData      = "Please review the Terraform plan and approve infrastructure changes. Check cost impact and security implications."
      }
    }
  }

  # Stage 5: Apply
  stage {
    name = "Apply"

    action {
      name             = "Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["plan_output"]
      output_artifacts = ["apply_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.iac_apply.name
      }
    }
  }

  # Stage 6: Notify
  stage {
    name = "Notify"

    action {
      name            = "Notify"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["apply_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.iac_notify.name
      }
    }
  }
}

# Data source for existing GitHub token
data "aws_secretsmanager_secret" "github_token" {
  name = "cloudmart/github-oauth-token"
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

# IAM Roles
resource "aws_iam_role" "iac_codepipeline_role" {
  name = "cloudmart-iac-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "iac_codebuild_role" {
  name = "cloudmart-iac-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policies
resource "aws_iam_role_policy" "iac_codepipeline_policy" {
  name = "cloudmart-iac-codepipeline-policy"
  role = aws_iam_role.iac_codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketVersioning",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.iac_pipeline_artifacts.arn,
          "${aws_s3_bucket.iac_pipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.iac_notifications.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "iac_codebuild_policy" {
  name = "cloudmart-iac-codebuild-policy"
  role = aws_iam_role.iac_codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.iac_pipeline_artifacts.arn,
          "${aws_s3_bucket.iac_pipeline_artifacts.arn}/*",
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.terraform_locks.arn
      },
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
      }
    ]
  })
}
