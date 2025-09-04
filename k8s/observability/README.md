# 📊 CloudMart Observability Stack

## 🎯 Overview

Complete observability solution for CloudMart's AI-powered e-commerce platform with:
- **AI Service Metrics**: OpenAI, AWS Bedrock, Azure AI performance
- **Business Intelligence**: Orders, revenue, customer satisfaction
- **Database Monitoring**: DynamoDB performance and costs
- **Infrastructure Metrics**: Kubernetes, AWS services

## 🚀 Quick Deploy

```bash
# Deploy complete observability stack
./deploy-observability.sh

# Install backend dependencies
cd backend && npm install prom-client
```

## 📈 Metrics Available

### AI Services
- `ai_request_duration_seconds` - AI API response times
- `ai_requests_total` - Total AI requests by service/status
- `ai_tokens_used_total` - Token consumption tracking
- `ai_cost_total` - Real-time AI service costs

### Business Metrics
- `orders_total` - Order counts by status/payment
- `customer_satisfaction_score` - AI sentiment analysis scores
- `http_request_duration_seconds` - API performance

### Database
- `database_operation_duration_seconds` - DynamoDB operation times
- `database_errors_total` - Database errors by type
- `aws_dynamodb_*` - CloudWatch DynamoDB metrics

## 🔍 Access Dashboards

### Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Visit: http://localhost:9090
```

### Backend Metrics
```bash
kubectl port-forward svc/cloudmart-backend 5000:5000
# Visit: http://localhost:5000/metrics
```

### CloudWatch Metrics
```bash
kubectl port-forward -n monitoring svc/cloudwatch-exporter 9106:9106
# Visit: http://localhost:9106/metrics
```

## 📊 Sample Queries

### AI Performance
```promql
# 95th percentile AI response time
histogram_quantile(0.95, rate(ai_request_duration_seconds_bucket[5m]))

# AI error rate by service
rate(ai_requests_total{status="error"}[5m])

# Token usage per minute
rate(ai_tokens_used_total[1m])
```

### Business Intelligence
```promql
# Orders per hour
rate(orders_total[1h])

# Customer satisfaction trend
customer_satisfaction_score

# API success rate
rate(http_requests_total{status="success"}[5m]) / rate(http_requests_total[5m])
```

### Database Performance
```promql
# Database operation latency
histogram_quantile(0.95, rate(database_operation_duration_seconds_bucket[5m]))

# DynamoDB read capacity utilization
aws_dynamodb_consumed_read_capacity_units_sum
```

## 🎯 Production Benefits

### Cost Optimization
- **AI Cost Tracking**: Real-time spend monitoring
- **Capacity Planning**: DynamoDB usage patterns
- **Performance Optimization**: Identify bottlenecks

### Business Intelligence
- **Customer Satisfaction**: AI-powered sentiment tracking
- **Revenue Metrics**: Order processing insights
- **Feature Usage**: AI service adoption rates

### Operational Excellence
- **Proactive Monitoring**: Issues detected before users
- **Performance SLAs**: 95th percentile tracking
- **Error Analysis**: Detailed failure categorization

## 🔧 Configuration

### Environment Variables
```bash
# Backend metrics
PROMETHEUS_ENABLED=true
METRICS_PORT=5000

# CloudWatch exporter
AWS_REGION=us-east-1
```

### Kubernetes Annotations
```yaml
# Enable Prometheus scraping
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "5000"
  prometheus.io/path: "/metrics"
```

## 🎖️ Enterprise Features

✅ **Multi-Cloud Monitoring** - AWS, Azure, GCP metrics  
✅ **AI Cost Optimization** - Real-time spend tracking  
✅ **Business Intelligence** - Customer satisfaction scores  
✅ **Performance SLAs** - 95th percentile monitoring  
✅ **Proactive Alerting** - Issues detected early  
✅ **Compliance Ready** - Audit trail metrics  

**This observability stack demonstrates production-ready monitoring that impresses in senior DevOps interviews!** 🚀
