#!/bin/bash

# CloudMart Observability Stack Deployment Script
# This script deploys Prometheus, Grafana, and Node Exporter to EKS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="cloudmart-cluster"
REGION="us-east-1"
NAMESPACE="monitoring"

echo -e "${BLUE}🚀 CloudMart Observability Stack Deployment${NC}"
echo "=============================================="

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl first.${NC}"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install AWS CLI first.${NC}"
    exit 1
fi

# Update kubeconfig
echo -e "${YELLOW}📋 Updating kubeconfig for EKS cluster...${NC}"
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Verify cluster connection
echo -e "${YELLOW}🔍 Verifying cluster connection...${NC}"
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to EKS cluster. Please check your configuration.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Connected to EKS cluster successfully${NC}"

# Deploy RBAC and namespace
echo -e "${YELLOW}🔐 Deploying RBAC and namespace...${NC}"
kubectl apply -f ../k8s/observability/rbac.yaml

# Wait for namespace to be ready
echo -e "${YELLOW}⏳ Waiting for namespace to be ready...${NC}"
kubectl wait --for=condition=Ready namespace/$NAMESPACE --timeout=60s

# Deploy Prometheus
echo -e "${YELLOW}📊 Deploying Prometheus...${NC}"
kubectl apply -f ../k8s/observability/prometheus-config.yaml
kubectl apply -f ../k8s/observability/prometheus-deployment.yaml

# Deploy Grafana
echo -e "${YELLOW}📈 Deploying Grafana...${NC}"
kubectl apply -f ../k8s/observability/grafana-deployment.yaml

# Deploy Node Exporter
echo -e "${YELLOW}🖥️  Deploying Node Exporter...${NC}"
kubectl apply -f ../k8s/observability/node-exporter.yaml

# Wait for deployments to be ready
echo -e "${YELLOW}⏳ Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n $NAMESPACE

# Check pod status
echo -e "${YELLOW}🔍 Checking pod status...${NC}"
kubectl get pods -n $NAMESPACE

# Get service information
echo -e "${YELLOW}🌐 Getting service information...${NC}"
kubectl get svc -n $NAMESPACE

# Port forwarding instructions
echo -e "${GREEN}✅ Observability stack deployed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Access Instructions:${NC}"
echo "======================="
echo ""
echo -e "${YELLOW}Prometheus:${NC}"
echo "kubectl port-forward -n $NAMESPACE svc/prometheus 9090:9090"
echo "Then access: http://localhost:9090"
echo ""
echo -e "${YELLOW}Grafana:${NC}"
echo "kubectl port-forward -n $NAMESPACE svc/grafana 3000:3000"
echo "Then access: http://localhost:3000"
echo "Default credentials: admin / cloudmart123"
echo ""
echo -e "${YELLOW}To check logs:${NC}"
echo "kubectl logs -f deployment/prometheus -n $NAMESPACE"
echo "kubectl logs -f deployment/grafana -n $NAMESPACE"
echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
