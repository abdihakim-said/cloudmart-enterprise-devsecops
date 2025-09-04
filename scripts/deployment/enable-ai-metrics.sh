#!/bin/bash

echo "🤖 Enabling AI Metrics in Production CloudMart Backend..."

# Backup current controller
echo "📦 Backing up current AI controller..."
kubectl exec -n default deployment/cloudmart-backend -- cp /app/src/controllers/aiController.js /app/src/controllers/aiController.backup.js

# Copy the updated controller with metrics
echo "🔄 Updating AI controller with metrics tracking..."
kubectl cp /Users/abdihakimsaid/sandbox/cloudmart-project/backend/src/controllers/aiController-with-metrics.js default/$(kubectl get pods -n default -l app=cloudmart-backend -o jsonpath='{.items[0].metadata.name}'):/app/src/controllers/aiController.js

# Restart backend pods to apply changes
echo "🔄 Restarting backend pods..."
kubectl rollout restart deployment/cloudmart-backend -n default

# Wait for rollout to complete
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/cloudmart-backend -n default --timeout=300s

# Verify metrics endpoint
echo "✅ Verifying AI metrics are available..."
sleep 30
kubectl port-forward svc/cloudmart-backend 5000:5000 &
PID=$!
sleep 5

echo "🔍 Checking for AI metrics..."
curl -s http://localhost:5000/metrics | grep -E "(ai_requests_total|ai_tokens_used|ai_cost_total)" | head -5

kill $PID

echo ""
echo "🎯 AI Metrics Integration Complete!"
echo ""
echo "📊 Available AI Metrics:"
echo "- ai_requests_total: Total AI service requests"
echo "- ai_tokens_used_total: AI tokens consumed"
echo "- ai_cost_total: AI service costs in USD"
echo "- customer_satisfaction_score: AI sentiment analysis"
echo ""
echo "🚀 Test AI endpoints to generate metrics:"
echo "curl -X POST https://app.cloudmartsaid.shop/api/ai/start -d '{\"message\":\"Hello\"}'"
echo "curl -X POST https://app.cloudmartsaid.shop/api/ai/bedrock/start -d '{\"message\":\"What products do you sell?\"}'"
echo ""
echo "📈 Add these queries to your Grafana dashboard:"
echo "- rate(ai_requests_total[1m])"
echo "- rate(ai_tokens_used_total[1m])"
echo "- ai_cost_total"
echo "- customer_satisfaction_score"
