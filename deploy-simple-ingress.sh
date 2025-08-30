#!/bin/bash
set -e

echo "🚀 Deploying CloudMart Simple Secure Ingress..."

# Update kubeconfig
echo "📋 Updating kubeconfig..."
aws eks update-kubeconfig --region us-east-1 --name cloudmart-cluster

# Check current services
echo "🔍 Checking current services..."
kubectl get svc

# Deploy simple secure ingress
echo "🚀 Deploying ingress..."
kubectl apply -f k8s/environments/production/ingress-production-simple.yaml

# Wait for ingress
echo "⏳ Waiting for ingress to be ready..."
sleep 30

# Get ingress status
echo "📊 Ingress status:"
kubectl get ingress cloudmart-secure-ingress

# Get ALB DNS
ALB_DNS=$(kubectl get ingress cloudmart-secure-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Pending...")

echo ""
echo "✅ Ingress deployed!"
echo "🔗 ALB DNS: $ALB_DNS"
echo ""
echo "🌐 Access URLs (once ready):"
echo "  Frontend: https://$ALB_DNS"
echo "  API: https://$ALB_DNS/api"
echo "  Health: https://$ALB_DNS/api/health"
echo ""
echo "⏳ Note: ALB provisioning takes 2-3 minutes..."
