#!/bin/bash

# Setup DevSecOps CI/CD Pipeline with GitHub Integration
# This script sets up the complete pipeline infrastructure

set -e

echo "🚀 Setting up CloudMart DevSecOps CI/CD Pipeline"

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is required but not installed."; exit 1; }

# Get GitHub information
read -p "Enter your GitHub username/organization: " GITHUB_OWNER
read -p "Enter your GitHub repository name (default: cloudmart-project): " GITHUB_REPO
GITHUB_REPO=${GITHUB_REPO:-cloudmart-project}

read -s -p "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
echo

# Validate GitHub token
echo "🔐 Validating GitHub token..."
if ! curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user > /dev/null; then
    echo "❌ Invalid GitHub token"
    exit 1
fi

# Store GitHub token in AWS Secrets Manager
echo "🔐 Storing GitHub token in AWS Secrets Manager..."
aws secretsmanager create-secret \
    --name "cloudmart/github-oauth-token" \
    --description "GitHub OAuth token for CodePipeline" \
    --secret-string "$GITHUB_TOKEN" \
    --region us-east-1 2>/dev/null || \
aws secretsmanager update-secret \
    --secret-id "cloudmart/github-oauth-token" \
    --secret-string "$GITHUB_TOKEN" \
    --region us-east-1

echo "✅ GitHub token stored successfully"

# Deploy CI/CD infrastructure
echo "🏗️ Deploying CI/CD infrastructure..."
cd terraform/

# Initialize Terraform
terraform init

# Create terraform.tfvars
cat > terraform.tfvars << EOF
github_owner = "$GITHUB_OWNER"
github_repo = "$GITHUB_REPO"
aws_region = "us-east-1"
environment = "production"
EOF

# Plan and apply
terraform plan -var-file=terraform.tfvars
read -p "Do you want to apply these changes? (y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    terraform apply -var-file=terraform.tfvars -auto-approve
else
    echo "❌ Deployment cancelled"
    exit 1
fi

cd ..

# Create buildspec files in repository root
echo "📝 Creating buildspec files..."
cp buildspec-security.yml ./
cp buildspec-build.yml ./
cp buildspec-deploy.yml ./

# Update Kubernetes manifests for CI/CD
echo "🔧 Updating Kubernetes manifests for CI/CD..."
find k8s -name "*.yaml" -type f -exec sed -i.bak 's|image: .*cloudmart.*|image: ECR_REPOSITORY_URI:IMAGE_TAG|g' {} \;

# Create GitHub webhook (optional)
echo "🔗 Setting up GitHub webhook..."
PIPELINE_NAME="cloudmart-devsecops-pipeline"
WEBHOOK_URL="https://codepipeline.us-east-1.amazonaws.com/webhooks?Action=StartPipelineExecution&PipelineName=$PIPELINE_NAME"

echo "
✅ CI/CD Pipeline Setup Complete!

📋 Next Steps:
1. Commit and push your code to GitHub repository: $GITHUB_OWNER/$GITHUB_REPO
2. The pipeline will automatically trigger on push to main branch
3. Monitor pipeline progress in AWS CodePipeline console

🔗 AWS Console Links:
- CodePipeline: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/$PIPELINE_NAME/view
- CodeBuild: https://console.aws.amazon.com/codesuite/codebuild/projects
- ECR: https://console.aws.amazon.com/ecr/repositories

📊 Pipeline Stages:
1. Source (GitHub) → Security Scan → Build & Test → Deploy

🔒 Security Features Enabled:
- Secrets detection with GitLeaks
- SAST scanning with Semgrep
- Container vulnerability scanning with Trivy
- Infrastructure security with Checkov
- Dependency vulnerability scanning

🚀 Your DevSecOps pipeline is ready!
"
