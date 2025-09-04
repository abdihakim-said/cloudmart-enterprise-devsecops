#!/bin/bash

echo "🚀 Deploying CloudMart Observability Stack..."

# Create monitoring namespace
echo "📊 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy Prometheus
echo "📈 Deploying Prometheus..."
kubectl apply -f k8s/observability/prometheus-deployment.yaml

# Deploy CloudWatch Exporter
echo "☁️ Deploying CloudWatch Exporter..."
kubectl apply -f k8s/observability/cloudwatch-exporter.yaml

# Deploy Grafana Dashboards
echo "📊 Deploying Grafana Dashboards..."
kubectl apply -f k8s/observability/grafana-dashboards.yaml

# Update backend service for metrics
echo "🔧 Updating backend service..."
kubectl apply -f k8s/base/backend-deployment.yaml

# Wait for deployments
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/cloudwatch-exporter -n monitoring

# Get service URLs
echo "🎯 Observability Stack Deployed Successfully!"
echo ""
echo "📊 Access URLs:"
echo "Prometheus: kubectl port-forward -n monitoring svc/prometheus 9090:9090"
echo "CloudWatch Metrics: kubectl port-forward -n monitoring svc/cloudwatch-exporter 9106:9106"
echo ""
echo "🔍 Check metrics endpoint:"
echo "Backend Metrics: kubectl port-forward svc/cloudmart-backend 5000:5000"
echo "Then visit: http://localhost:5000/metrics"
echo ""
echo "✅ Your AI services are now fully monitored!"
