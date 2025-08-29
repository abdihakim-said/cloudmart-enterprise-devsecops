# Ingress Configuration by Environment

## 📁 **File Structure**

```
├── ingress-development.yaml     # Local development
├── k8s/
│   ├── ingress-production.yaml  # Production AWS
│   └── app/
│       └── ingress-staging.yaml # Staging environment
```

## 🌍 **Environment Configurations**

### **Development** (`ingress-development.yaml`)
- **Controller**: NGINX Ingress
- **Domain**: www.hakimdevops.art
- **Use Case**: Local development, testing
- **Features**: Simple routing, custom domain

```bash
# Deploy to development
kubectl apply -f ingress-development.yaml
```

### **Production** (`k8s/ingress-production.yaml`) ✅ **CURRENTLY ACTIVE**
- **Controller**: AWS Application Load Balancer (ALB)
- **Access**: Internet-facing
- **URL**: k8s-default-cloudmar-4d66794f32-1622144724.us-east-1.elb.amazonaws.com
- **Features**: Auto-scaling, health checks, AWS integration

```bash
# Deploy to production
kubectl apply -f k8s/ingress-production.yaml
```

### **Staging** (`k8s/app/ingress-staging.yaml`)
- **Controller**: NGINX Ingress
- **Use Case**: Pre-production testing
- **Features**: Production-like testing environment

```bash
# Deploy to staging
kubectl apply -f k8s/app/ingress-staging.yaml
```

## 🚀 **Deployment Commands**

### **Switch Between Environments**

```bash
# Development
kubectl delete ingress --all
kubectl apply -f ingress-development.yaml

# Staging
kubectl delete ingress --all
kubectl apply -f k8s/app/ingress-staging.yaml

# Production (Current)
kubectl delete ingress --all
kubectl apply -f k8s/ingress-production.yaml
```

## 📊 **Environment Comparison**

| Environment | Controller | Domain | Features |
|-------------|------------|--------|----------|
| **Development** | NGINX | Custom | Simple, Fast |
| **Staging** | NGINX | Default | Testing |
| **Production** | AWS ALB | Load Balancer | Enterprise, Scalable |

## ✅ **Current Status**
- **Active**: Production environment
- **Ingress**: cloudmart-production-ingress
- **Controller**: AWS ALB
- **Status**: ✅ Working
