#!/bin/bash

# CloudMart Environment Setup Script
# This script sets up the development environment for CloudMart

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="CloudMart"
REQUIRED_TOOLS=("terraform" "kubectl" "docker" "aws" "node" "npm")

echo -e "${BLUE}🚀 ${PROJECT_NAME} Environment Setup${NC}"
echo "=============================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check tool versions
check_tool_version() {
    local tool=$1
    local min_version=$2
    
    if command_exists "$tool"; then
        local version
        case $tool in
            "terraform")
                version=$(terraform version | head -n1 | cut -d'v' -f2)
                ;;
            "kubectl")
                version=$(kubectl version --client --short | cut -d'v' -f3)
                ;;
            "docker")
                version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
                ;;
            "aws")
                version=$(aws --version | cut -d'/' -f2 | cut -d' ' -f1)
                ;;
            "node")
                version=$(node --version | cut -d'v' -f2)
                ;;
            "npm")
                version=$(npm --version)
                ;;
        esac
        echo -e "${GREEN}✅ $tool: v$version${NC}"
    else
        echo -e "${RED}❌ $tool: Not installed${NC}"
        return 1
    fi
}

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
missing_tools=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! check_tool_version "$tool"; then
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -ne 0 ]; then
    echo -e "${RED}❌ Missing required tools: ${missing_tools[*]}${NC}"
    echo -e "${YELLOW}Please install the missing tools and run this script again.${NC}"
    exit 1
fi

# Check AWS credentials
echo -e "${YELLOW}🔐 Checking AWS credentials...${NC}"
if aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${GREEN}✅ AWS credentials configured${NC}"
else
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo -e "${YELLOW}Please run 'aws configure' to set up your credentials.${NC}"
    exit 1
fi

# Create necessary directories
echo -e "${YELLOW}📁 Creating project directories...${NC}"
directories=(
    "logs"
    "tmp"
    "config/local"
    "docker/data"
    "monitoring/data"
    "tests/reports"
    "docs/generated"
)

for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${GREEN}✅ Created directory: $dir${NC}"
    fi
done

# Copy example configuration files
echo -e "${YELLOW}⚙️ Setting up configuration files...${NC}"

# Terraform variables
if [ ! -f "terraform/terraform.tfvars" ]; then
    if [ -f "terraform/terraform.tfvars.example" ]; then
        cp terraform/terraform.tfvars.example terraform/terraform.tfvars
        echo -e "${GREEN}✅ Created terraform/terraform.tfvars${NC}"
        echo -e "${YELLOW}⚠️  Please update terraform/terraform.tfvars with your values${NC}"
    fi
fi

# Environment files
for env in frontend backend; do
    if [ ! -f "$env/.env" ] && [ -f "$env/.env.example" ]; then
        cp "$env/.env.example" "$env/.env"
        echo -e "${GREEN}✅ Created $env/.env${NC}"
    fi
done

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"

# Frontend dependencies
if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
    echo -e "${BLUE}Installing frontend dependencies...${NC}"
    cd frontend
    npm ci
    cd ..
    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
fi

# Backend dependencies
if [ -d "backend" ] && [ -f "backend/package.json" ]; then
    echo -e "${BLUE}Installing backend dependencies...${NC}"
    cd backend
    npm ci
    cd ..
    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
fi

# Initialize Terraform
echo -e "${YELLOW}🏗️ Initializing Terraform...${NC}"
if [ -d "terraform" ]; then
    cd terraform
    terraform init
    cd ..
    echo -e "${GREEN}✅ Terraform initialized${NC}"
fi

# Set up Git hooks (if .git exists)
if [ -d ".git" ]; then
    echo -e "${YELLOW}🪝 Setting up Git hooks...${NC}"
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# CloudMart pre-commit hook

echo "Running pre-commit checks..."

# Check for secrets
if command -v gitleaks >/dev/null 2>&1; then
    gitleaks detect --source . --verbose
fi

# Run linting
if [ -d "frontend" ]; then
    cd frontend && npm run lint
    cd ..
fi

if [ -d "backend" ]; then
    cd backend && npm run lint
    cd ..
fi

echo "Pre-commit checks completed."
EOF

    chmod +x .git/hooks/pre-commit
    echo -e "${GREEN}✅ Git hooks configured${NC}"
fi

# Create local development script
echo -e "${YELLOW}🔧 Creating local development helpers...${NC}"

cat > tools/local-development/start-services.sh << 'EOF'
#!/bin/bash
# Start local development services

echo "🚀 Starting CloudMart local development environment..."

# Start Docker Compose services
docker-compose -f config/docker-compose.yml up -d

echo "✅ Local services started!"
echo "📊 Grafana: http://localhost:3001 (admin/admin123)"
echo "🔍 Kibana: http://localhost:5601"
echo "📈 Prometheus: http://localhost:9090"
echo "🗄️ DynamoDB Local: http://localhost:8000"
echo "🔄 Redis: localhost:6379"
echo "📦 MinIO: http://localhost:9001 (minioadmin/minioadmin123)"
EOF

chmod +x tools/local-development/start-services.sh

cat > tools/local-development/stop-services.sh << 'EOF'
#!/bin/bash
# Stop local development services

echo "🛑 Stopping CloudMart local development environment..."

# Stop Docker Compose services
docker-compose -f config/docker-compose.yml down

echo "✅ Local services stopped!"
EOF

chmod +x tools/local-development/stop-services.sh

# Final setup verification
echo -e "${YELLOW}🔍 Running setup verification...${NC}"

# Check if Terraform can validate
if [ -d "terraform" ]; then
    cd terraform
    if terraform validate >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Terraform configuration valid${NC}"
    else
        echo -e "${YELLOW}⚠️  Terraform validation warnings (check terraform/terraform.tfvars)${NC}"
    fi
    cd ..
fi

# Check Docker
if docker info >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker is running${NC}"
else
    echo -e "${YELLOW}⚠️  Docker is not running${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Environment setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Update terraform/terraform.tfvars with your AWS account details"
echo "2. Update frontend/.env and backend/.env with your configuration"
echo "3. Run './tools/local-development/start-services.sh' to start local services"
echo "4. Run 'terraform plan' to review infrastructure changes"
echo "5. Run 'terraform apply' to deploy infrastructure"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "• Start local services: ./tools/local-development/start-services.sh"
echo "• Stop local services: ./tools/local-development/stop-services.sh"
echo "• Deploy infrastructure: cd terraform && terraform apply"
echo "• Deploy monitoring: ./scripts/deploy-observability.sh"
echo ""
echo -e "${YELLOW}📚 Documentation: Check docs/ directory for detailed guides${NC}"
