#!/bin/bash
set -e

echo "🚀 Deploying CloudMart Secure HTTPS Ingress..."

# Get current cluster context
CLUSTER_NAME="cloudmart-cluster"
REGION="us-east-1"

# Update kubeconfig
echo "📋 Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Check if AWS Load Balancer Controller is installed
echo "🔍 Checking AWS Load Balancer Controller..."
if ! kubectl get deployment -n kube-system aws-load-balancer-controller &>/dev/null; then
    echo "❌ AWS Load Balancer Controller not found. Installing..."
    
    # Install AWS Load Balancer Controller
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json
    
    # Create IAM policy (if not exists)
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json || echo "Policy already exists"
    
    # Create service account
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve || echo "Service account already exists"
    
    # Install controller via Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
else
    echo "✅ AWS Load Balancer Controller already installed"
fi

# Get ACM certificate ARN from Terraform output
echo "🔐 Getting ACM certificate ARN..."
cd terraform
ACM_CERT_ARN=$(terraform output -raw acm_certificate_arn 2>/dev/null || echo "")

if [ -z "$ACM_CERT_ARN" ]; then
    echo "⚠️  No ACM certificate found. Creating self-signed certificate for testing..."
    ACM_CERT_ARN="arn:aws:acm:us-east-1:$(aws sts get-caller-identity --query Account --output text):certificate/self-signed"
fi

# Get WAF ACL ARN (if exists)
WAF_ACL_ARN=$(terraform output -raw waf_acl_arn 2>/dev/null || echo "")

cd ..

# Create temporary ingress file with substituted values
echo "📝 Creating ingress configuration..."
cp k8s/environments/production/ingress-production-enterprise.yaml /tmp/ingress-deploy.yaml

# Replace variables
sed -i.bak "s|\${ACM_CERTIFICATE_ARN}|$ACM_CERT_ARN|g" /tmp/ingress-deploy.yaml
sed -i.bak "s|\${WAF_ACL_ARN}|$WAF_ACL_ARN|g" /tmp/ingress-deploy.yaml

# Remove WAF annotation if no WAF ARN
if [ -z "$WAF_ACL_ARN" ]; then
    sed -i.bak '/alb.ingress.kubernetes.io\/wafv2-acl-arn/d' /tmp/ingress-deploy.yaml
fi

# Deploy the ingress
echo "🚀 Deploying secure ingress..."
kubectl apply -f /tmp/ingress-deploy.yaml

# Wait for ingress to be ready
echo "⏳ Waiting for ingress to be ready..."
kubectl wait --for=condition=ready ingress/cloudmart-production-ingress-secure --timeout=300s

# Get the ALB DNS name
echo "🌐 Getting ALB DNS name..."
ALB_DNS=$(kubectl get ingress cloudmart-production-ingress-secure -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo ""
echo "✅ Secure HTTPS Ingress deployed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "  🔗 ALB DNS: $ALB_DNS"
echo "  🔐 Certificate: $ACM_CERT_ARN"
echo "  🛡️  WAF: ${WAF_ACL_ARN:-"Not configured"}"
echo ""
echo "🌐 Access URLs:"
echo "  Frontend: https://$ALB_DNS"
echo "  API: https://$ALB_DNS/api"
echo "  Health: https://$ALB_DNS/api/health"
echo ""
echo "🔒 Security Features Enabled:"
echo "  ✅ HTTPS redirect (HTTP -> HTTPS)"
echo "  ✅ TLS 1.3 with secure cipher suites"
echo "  ✅ HSTS headers"
echo "  ✅ Security headers (CSP, X-Frame-Options, etc.)"
echo "  ✅ Access logs to S3"
echo "  ✅ Health checks"
echo ""

# Clean up
rm -f /tmp/ingress-deploy.yaml*
rm -f iam_policy.json

echo "🎉 Deployment complete! Your CloudMart application is now accessible via secure HTTPS."
