# 🔒 CloudMart Enterprise Ingress with TLS Security

## Overview

This document outlines the production-grade ingress implementation for CloudMart with enterprise-level security features including TLS 1.3, WAF protection, and comprehensive security headers.

## 🏗️ Architecture

```
Internet → Route53 → ALB (TLS 1.3) → WAF → EKS Ingress → Services
                ↓
            ACM Certificate
```

## 🔐 Security Features

### TLS Configuration
- **TLS Policy**: `ELBSecurityPolicy-TLS13-1-2-2021-06` (Latest AWS TLS policy)
- **Certificate**: AWS Certificate Manager (ACM) with automatic renewal
- **HSTS**: Strict-Transport-Security header with 1-year max-age
- **SSL Redirect**: Automatic HTTP to HTTPS redirection

### Security Headers
```yaml
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'...
```

### WAF Protection
- **AWS Managed Rules**: Common Rule Set, Known Bad Inputs, SQL Injection
- **Rate Limiting**: 2000 requests per minute per IP
- **DDoS Protection**: Built-in AWS Shield Standard
- **Logging**: CloudWatch integration for security monitoring

## 📁 File Structure

```
terraform/modules/
├── acm/                    # SSL Certificate management
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── waf/                    # Web Application Firewall
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

k8s/environments/production/
├── ingress-production-enterprise.yaml    # Main enterprise ingress
└── monitoring-ingress.yaml              # Monitoring ingress

k8s/infrastructure/
├── network-policies.yaml                # Network security policies
└── waf.yaml                             # WAF configuration

scripts/
└── deploy-enterprise-ingress.sh         # Automated deployment
```

## 🚀 Deployment

### Prerequisites
```bash
# Required tools
kubectl >= 1.28.0
aws-cli >= 2.0
terraform >= 1.5.0

# AWS permissions
- ACM certificate management
- WAF configuration
- Route53 DNS management
- EKS cluster access
```

### Quick Deployment
```bash
# Clone and navigate
git clone <repository>
cd cloudmart-enterprise-devsecops

# Set environment variables
export DOMAIN_NAME="your-domain.com"
export ROUTE53_ZONE_ID="Z1234567890"

# Deploy enterprise ingress
./scripts/deploy-enterprise-ingress.sh
```

### Manual Deployment
```bash
# 1. Deploy infrastructure
cd terraform/
terraform init
terraform plan -target=module.acm -target=module.waf
terraform apply -target=module.acm -target=module.waf

# 2. Get ARNs
CERT_ARN=$(terraform output -raw acm_certificate_arn)
WAF_ARN=$(terraform output -raw waf_acl_arn)

# 3. Update ingress configuration
sed -i "s/\${ACM_CERTIFICATE_ARN}/${CERT_ARN}/g" k8s/environments/production/ingress-production-enterprise.yaml
sed -i "s/\${WAF_ACL_ARN}/${WAF_ARN}/g" k8s/environments/production/ingress-production-enterprise.yaml

# 4. Deploy Kubernetes resources
kubectl apply -f k8s/infrastructure/network-policies.yaml
kubectl apply -f k8s/infrastructure/waf.yaml
kubectl apply -f k8s/environments/production/ingress-production-enterprise.yaml
```

## 🔧 Configuration

### Domain Configuration
Update `terraform/variables.tf`:
```hcl
variable "domain_name" {
  default = "your-domain.com"
}

variable "subject_alternative_names" {
  default = ["*.your-domain.com", "api.your-domain.com"]
}
```

### WAF Rules Customization
Modify `terraform/modules/waf/main.tf` to adjust:
- Rate limiting thresholds
- Custom rule groups
- IP whitelisting/blacklisting
- Geographic restrictions

### Security Headers
Customize headers in `ingress-production-enterprise.yaml`:
```yaml
alb.ingress.kubernetes.io/actions.response-headers: |
  {
    "ResponseHeaders": {
      "Custom-Security-Header": "your-value"
    }
  }
```

## 📊 Monitoring & Observability

### CloudWatch Metrics
- **WAF Metrics**: Blocked requests, allowed requests, rate limit hits
- **ALB Metrics**: Request count, response time, error rates
- **Certificate Metrics**: Days until expiration

### Grafana Dashboards
Access monitoring at: `http://your-grafana-url/grafana/`
- ALB Performance Dashboard
- WAF Security Dashboard
- Certificate Expiration Alerts

### Log Analysis
```bash
# WAF logs
aws logs describe-log-groups --log-group-name-prefix "/aws/wafv2/cloudmart"

# ALB access logs
aws s3 ls s3://cloudmart-alb-logs-production/enterprise-ingress/
```

## 🔍 Security Validation

### TLS Testing
```bash
# Test TLS configuration
openssl s_client -connect your-domain.com:443 -servername your-domain.com

# Check certificate details
curl -vI https://your-domain.com 2>&1 | grep -E "(SSL|TLS|certificate)"
```

### Security Headers Testing
```bash
# Validate security headers
curl -I https://your-domain.com | grep -E "(Strict-Transport|X-Content|X-Frame)"

# Use online tools
# - https://securityheaders.com/
# - https://www.ssllabs.com/ssltest/
```

### WAF Testing
```bash
# Test rate limiting (adjust URL)
for i in {1..100}; do curl -s https://your-domain.com/api/health; done

# Test SQL injection protection
curl "https://your-domain.com/api/products?id=1' OR '1'='1"
```

## 🚨 Troubleshooting

### Common Issues

#### Certificate Validation Fails
```bash
# Check DNS records
dig TXT _acme-challenge.your-domain.com

# Verify Route53 zone
aws route53 list-hosted-zones --query "HostedZones[?Name=='your-domain.com.']"
```

#### Ingress Not Ready
```bash
# Check ingress status
kubectl describe ingress cloudmart-production-enterprise-ingress

# Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

#### WAF Blocking Legitimate Traffic
```bash
# Check WAF logs
aws wafv2 get-sampled-requests --web-acl-arn $WAF_ARN --rule-metric-name RateLimitRuleMetric

# Temporarily disable rules for testing
aws wafv2 update-web-acl --scope REGIONAL --id $WAF_ID --default-action Allow={}
```

## 🔄 Maintenance

### Certificate Renewal
ACM certificates auto-renew. Monitor via CloudWatch:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/CertificateManager \
  --metric-name DaysToExpiry \
  --dimensions Name=CertificateArn,Value=$CERT_ARN
```

### WAF Rule Updates
```bash
# Update managed rule groups
terraform plan -target=module.waf
terraform apply -target=module.waf
```

### Security Policy Updates
```bash
# Update TLS policy
kubectl patch ingress cloudmart-production-enterprise-ingress \
  -p '{"metadata":{"annotations":{"alb.ingress.kubernetes.io/ssl-policy":"ELBSecurityPolicy-TLS13-1-2-2021-06"}}}'
```

## 📋 Compliance

### SOC 2 Requirements
- ✅ Encryption in transit (TLS 1.3)
- ✅ Access logging (ALB + WAF logs)
- ✅ Network segmentation (Network policies)
- ✅ Intrusion detection (WAF rules)
- ✅ Security monitoring (CloudWatch)

### GDPR Considerations
- Data encryption in transit
- Access logging with PII redaction
- Geographic restrictions (configurable)
- Right to be forgotten (log retention policies)

## 🎯 Performance Optimization

### HTTP/2 Support
Enabled by default in ALB configuration:
```yaml
routing.http2.enabled=true
```

### Connection Optimization
```yaml
idle_timeout.timeout_seconds=60
routing.http.preserve_host_header.enabled=true
```

### Caching Strategy
Consider implementing:
- CloudFront CDN for static assets
- Application-level caching
- Database query optimization

## 📞 Support

For issues or questions:
1. Check CloudWatch logs and metrics
2. Review Kubernetes events: `kubectl get events`
3. Validate DNS and certificate status
4. Test security configurations

## 🔗 References

- [AWS ALB Ingress Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [AWS WAF Documentation](https://docs.aws.amazon.com/waf/)
- [ACM Certificate Management](https://docs.aws.amazon.com/acm/)
- [Kubernetes Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
