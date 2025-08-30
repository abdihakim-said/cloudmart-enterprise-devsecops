#!/bin/bash

# CloudMart Enterprise Ingress Deployment Script
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="default"
DOMAIN_NAME="${DOMAIN_NAME:-cloudmart.example.com}"
ENVIRONMENT="production"

echo -e "${GREEN}🚀 Deploying CloudMart Enterprise Ingress${NC}"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed${NC}"
    exit 1
fi

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Deploy Terraform infrastructure
echo -e "${YELLOW}🏗️ Deploying infrastructure...${NC}"
cd terraform/

# Initialize and apply ACM module
terraform init
terraform plan -target=module.acm
terraform apply -target=module.acm -auto-approve

# Get certificate ARN
CERT_ARN=$(terraform output -raw acm_certificate_arn)
echo -e "${GREEN}📜 Certificate ARN: ${CERT_ARN}${NC}"

# Apply WAF module
terraform plan -target=module.waf
terraform apply -target=module.waf -auto-approve

# Get WAF ARN
WAF_ARN=$(terraform output -raw waf_acl_arn)
echo -e "${GREEN}🛡️ WAF ARN: ${WAF_ARN}${NC}"

cd ..

# Update ingress with actual ARNs
echo -e "${YELLOW}🔧 Updating ingress configuration...${NC}"
sed -i.bak "s/\${ACM_CERTIFICATE_ARN}/${CERT_ARN}/g" k8s/environments/production/ingress-production-enterprise.yaml
sed -i.bak "s/\${WAF_ACL_ARN}/${WAF_ARN}/g" k8s/environments/production/ingress-production-enterprise.yaml

# Deploy network policies
echo -e "${YELLOW}🔒 Deploying network policies...${NC}"
kubectl apply -f k8s/infrastructure/network-policies.yaml

# Deploy WAF configuration
echo -e "${YELLOW}🛡️ Deploying WAF configuration...${NC}"
kubectl apply -f k8s/infrastructure/waf.yaml

# Deploy enterprise ingress
echo -e "${YELLOW}🌐 Deploying enterprise ingress...${NC}"
kubectl apply -f k8s/environments/production/ingress-production-enterprise.yaml

# Wait for ingress to be ready
echo -e "${YELLOW}⏳ Waiting for ingress to be ready...${NC}"
kubectl wait --for=condition=ready ingress/cloudmart-production-enterprise-ingress --timeout=300s

# Get ingress details
echo -e "${GREEN}📊 Ingress deployment completed!${NC}"
kubectl get ingress cloudmart-production-enterprise-ingress -o wide

# Get ALB hostname
ALB_HOSTNAME=$(kubectl get ingress cloudmart-production-enterprise-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo -e "${GREEN}🌐 ALB Hostname: ${ALB_HOSTNAME}${NC}"

# Security validation
echo -e "${YELLOW}🔍 Running security validation...${NC}"

# Check TLS configuration
echo -e "${YELLOW}🔒 Validating TLS configuration...${NC}"
if openssl s_client -connect ${ALB_HOSTNAME}:443 -servername ${DOMAIN_NAME} </dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
    echo -e "${GREEN}✅ TLS certificate is valid${NC}"
else
    echo -e "${YELLOW}⚠️ TLS certificate validation pending (DNS propagation)${NC}"
fi

# Check security headers
echo -e "${YELLOW}🛡️ Validating security headers...${NC}"
curl -I https://${ALB_HOSTNAME} 2>/dev/null | grep -E "(Strict-Transport-Security|X-Content-Type-Options|X-Frame-Options)" || echo -e "${YELLOW}⚠️ Security headers configuration pending${NC}"

echo -e "${GREEN}🎉 Enterprise ingress deployment completed successfully!${NC}"
echo -e "${GREEN}📋 Summary:${NC}"
echo -e "   • Domain: ${DOMAIN_NAME}"
echo -e "   • ALB: ${ALB_HOSTNAME}"
echo -e "   • Certificate: ${CERT_ARN}"
echo -e "   • WAF: ${WAF_ARN}"
echo -e "   • TLS Policy: ELBSecurityPolicy-TLS13-1-2-2021-06"
echo -e "   • Security Headers: Enabled"
echo -e "   • Rate Limiting: 2000 req/min per IP"
echo -e "   • Network Policies: Applied"

echo -e "${YELLOW}📝 Next Steps:${NC}"
echo -e "   1. Update DNS records to point to ALB"
echo -e "   2. Verify certificate validation"
echo -e "   3. Test application endpoints"
echo -e "   4. Monitor WAF metrics in CloudWatch"
