# CloudMart Deployment Guide

## 🚀 **Complete Deployment Workflow**

This guide walks you through deploying the entire CloudMart platform from scratch.

## **Prerequisites**

### Required Tools
```bash
# Install required tools
brew install terraform kubectl awscli helm
npm install -g @aws-cdk/cli

# Verify installations
terraform --version
kubectl version --client
aws --version
```

### AWS Configuration
```bash
# Configure AWS CLI
aws configure
# Enter your AWS Access Key ID, Secret, Region (us-east-1), and output format (json)

# Verify access
aws sts get-caller-identity
```

## **Step 1: Infrastructure Deployment**

### Deploy Core Infrastructure
```bash
# Navigate to terraform directory
cd terraform/

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply infrastructure
terraform apply
# Type 'yes' when prompted

# Expected output:
# ✅ VPC and networking
# ✅ EKS cluster
# ✅ DynamoDB tables
# ✅ Lambda functions
# ✅ ECR repositories
# ✅ Observability stack
```

### Verify Infrastructure
```bash
# Check EKS cluster
aws eks describe-cluster --name cloudmart-cluster --region us-east-1

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name cloudmart-cluster

# Verify cluster access
kubectl get nodes
```

## **Step 2: Container Images**

### Build and Push Images
```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build frontend image
cd frontend/
docker build -t cloudmart-frontend .
docker tag cloudmart-frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/cloudmart-frontend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/cloudmart-frontend:latest

# Build backend image
cd ../backend/
docker build -t cloudmart-backend .
docker tag cloudmart-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/cloudmart-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/cloudmart-backend:latest
```

## **Step 3: Deploy Observability Stack**

```bash
# Deploy monitoring stack
cd ../scripts/
./deploy-observability.sh

# Verify deployment
kubectl get pods -n monitoring

# Expected output:
# prometheus-xxx        1/1     Running
# grafana-xxx           1/1     Running
# node-exporter-xxx     1/1     Running (on each node)
```

## **Step 4: Deploy Applications**

### Update Manifests
```bash
# Replace placeholders in K8s manifests
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com"

# Update image references
sed -i "s|ECR_REGISTRY|$ECR_REGISTRY|g" k8s/app/*.yaml
sed -i "s|IMAGE_TAG|latest|g" k8s/app/*.yaml
sed -i "s|ACCOUNT_ID|$AWS_ACCOUNT_ID|g" k8s/app/*.yaml
```

### Deploy Applications
```bash
# Deploy applications
kubectl apply -f k8s/app/

# Wait for deployments
kubectl rollout status deployment/cloudmart-frontend
kubectl rollout status deployment/cloudmart-backend

# Verify pods are running
kubectl get pods
```

## **Step 5: Configure Load Balancer**

### Install AWS Load Balancer Controller
```bash
# Create IAM policy
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Create service account
eksctl create iamserviceaccount \
  --cluster=cloudmart-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# Install controller via Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=cloudmart-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

## **Step 6: Access Applications**

### Get Load Balancer URL
```bash
# Wait for ingress to get external IP
kubectl get ingress cloudmart-frontend-ingress

# Get the load balancer URL
export LB_URL=$(kubectl get ingress cloudmart-frontend-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$LB_URL"
```

### Port Forward (Alternative)
```bash
# Frontend
kubectl port-forward svc/cloudmart-frontend 3000:3000

# Backend
kubectl port-forward svc/cloudmart-backend 5000:5000

# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

## **Step 7: Verify Deployment**

### Health Checks
```bash
# Check application health
curl http://$LB_URL/health

# Check backend API
curl http://$LB_URL/api/products

# Check metrics endpoint
curl http://$LB_URL/metrics
```

### Monitor Logs
```bash
# Application logs
kubectl logs -f deployment/cloudmart-frontend
kubectl logs -f deployment/cloudmart-backend

# Monitoring logs
kubectl logs -f deployment/prometheus -n monitoring
kubectl logs -f deployment/grafana -n monitoring
```

## **Step 8: Configure CI/CD (Optional)**

### GitHub Actions Setup
1. Fork the repository
2. Add GitHub secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`
3. Push to main branch to trigger deployment

### Manual Deployment Updates
```bash
# Build new images with version tag
docker build -t cloudmart-frontend:v1.1.0 frontend/
docker tag cloudmart-frontend:v1.1.0 $ECR_REGISTRY/cloudmart-frontend:v1.1.0
docker push $ECR_REGISTRY/cloudmart-frontend:v1.1.0

# Update deployment
kubectl set image deployment/cloudmart-frontend frontend=$ECR_REGISTRY/cloudmart-frontend:v1.1.0

# Monitor rollout
kubectl rollout status deployment/cloudmart-frontend
```

## **🔧 Troubleshooting**

### Common Issues

#### EKS Cluster Access Denied
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name cloudmart-cluster

# Check IAM permissions
aws sts get-caller-identity
```

#### Pods Stuck in Pending
```bash
# Check node capacity
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>

# Scale cluster if needed
aws eks update-nodegroup-config \
  --cluster-name cloudmart-cluster \
  --nodegroup-name cloudmart-nodes \
  --scaling-config minSize=2,maxSize=6,desiredSize=4
```

#### Load Balancer Not Working
```bash
# Check ingress status
kubectl describe ingress cloudmart-frontend-ingress

# Check AWS Load Balancer Controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## **📊 Post-Deployment Verification**

### Performance Tests
```bash
# Install hey for load testing
go install github.com/rakyll/hey@latest

# Run load test
hey -n 1000 -c 10 http://$LB_URL/api/products
```

### Monitoring Setup
1. Access Grafana: `http://localhost:3000` (admin/cloudmart123)
2. Import CloudMart dashboards
3. Set up alerts for critical metrics
4. Configure notification channels

## **🎯 Success Criteria**

✅ All pods running and healthy  
✅ Load balancer accessible externally  
✅ API endpoints responding correctly  
✅ Monitoring stack operational  
✅ Logs flowing to CloudWatch  
✅ Metrics visible in Grafana  

## **📞 Support**

If you encounter issues:
1. Check the troubleshooting section
2. Review pod/service logs
3. Verify AWS permissions
4. Consult the team documentation

---

**Deployment Time**: ~30-45 minutes  
**Last Updated**: August 2025  
**Version**: 1.0
