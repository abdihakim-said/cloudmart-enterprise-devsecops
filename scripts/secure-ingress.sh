#!/bin/bash

# CloudMart Ingress Security Script
# This script secures your CloudMart application with HTTPS/TLS

set -e

echo "🔒 Securing CloudMart Ingress with HTTPS/TLS..."

# Configuration
DOMAIN_NAME="${DOMAIN_NAME:-cloudmart.example.com}"
REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-cloudmart-cluster}"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "📋 AWS Account ID: $ACCOUNT_ID"

# Step 1: Request SSL Certificate from ACM
echo "📜 Requesting SSL certificate for domain: $DOMAIN_NAME"

CERT_ARN=$(aws acm request-certificate \
    --domain-name "$DOMAIN_NAME" \
    --subject-alternative-names "www.$DOMAIN_NAME" \
    --validation-method DNS \
    --region "$REGION" \
    --query CertificateArn \
    --output text)

echo "✅ Certificate requested: $CERT_ARN"
echo "⚠️  Please validate the certificate in ACM console before proceeding"

# Step 2: Create S3 bucket for ALB logs
BUCKET_NAME="cloudmart-alb-logs-$(date +%s)"
echo "📦 Creating S3 bucket for ALB logs: $BUCKET_NAME"

aws s3 mb "s3://$BUCKET_NAME" --region "$REGION" || echo "Bucket may already exist"

# Create bucket policy for ALB logs
cat > /tmp/alb-logs-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::127311923021:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/production/AWSLogs/$ACCOUNT_ID/*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/production/AWSLogs/$ACCOUNT_ID/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::127311923021:root"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::$BUCKET_NAME"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file:///tmp/alb-logs-policy.json

# Step 3: Update ingress configuration
echo "🔧 Updating ingress configuration..."

# Create the secure ingress with actual values
cat > /tmp/ingress-production-secure.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cloudmart-production-ingress-secure
  annotations:
    # ALB Configuration
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/ip-address-type: ipv4
    
    # HTTPS Configuration
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/certificate-arn: $CERT_ARN
    
    # Security Headers
    alb.ingress.kubernetes.io/actions.ssl-redirect: |
      {
        "Type": "redirect",
        "RedirectConfig": {
          "Protocol": "HTTPS",
          "Port": "443",
          "StatusCode": "HTTP_301"
        }
      }
    
    # Health Checks
    alb.ingress.kubernetes.io/healthcheck-path: /
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '3'
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    
    # Performance & Security
    alb.ingress.kubernetes.io/load-balancer-attributes: |
      idle_timeout.timeout_seconds=60,
      routing.http2.enabled=true,
      access_logs.s3.enabled=true,
      access_logs.s3.bucket=$BUCKET_NAME,
      access_logs.s3.prefix=production
    
    # Security Policy
    alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS-1-2-2017-01
    
    # Tags
    alb.ingress.kubernetes.io/tags: |
      Environment=production,
      Project=CloudMart,
      ManagedBy=Kubernetes,
      Security=HTTPS
      
spec:
  rules:
  - http:
      paths:
      # API Health Check
      - path: /api/health
        pathType: Exact
        backend:
          service:
            name: cloudmart-backend
            port:
              number: 5000
      
      # Backend API routes
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: cloudmart-backend
            port:
              number: 5000
      
      # Frontend static assets
      - path: /assets
        pathType: Prefix
        backend:
          service:
            name: cloudmart-frontend
            port:
              number: 80
              
      # Frontend routes (catch-all, must be last)
      - path: /
        pathType: Prefix
        backend:
          service:
            name: cloudmart-frontend
            port:
              number: 80
EOF

# Step 4: Apply the secure ingress
echo "🚀 Applying secure ingress configuration..."
kubectl apply -f /tmp/ingress-production-secure.yaml

# Step 5: Wait for certificate validation
echo "⏳ Waiting for certificate validation..."
echo "Please complete DNS validation in ACM console, then run:"
echo "kubectl get ingress cloudmart-production-ingress-secure"

# Clean up temp files
rm -f /tmp/alb-logs-policy.json /tmp/ingress-production-secure.yaml

echo ""
echo "🎉 Ingress security configuration completed!"
echo "📋 Certificate ARN: $CERT_ARN"
echo "📦 ALB Logs Bucket: $BUCKET_NAME"
echo ""
echo "Next steps:"
echo "1. Complete DNS validation in ACM console"
echo "2. Update your DNS to point to the new ALB"
echo "3. Test HTTPS access to your application"
echo ""
echo "🔒 Your CloudMart will be secured with HTTPS once certificate is validated!"
