# Kubernetes Deployment Guide

## 📁 **Directory Structure**

```
k8s/
├── base/                    # Core application manifests
├── environments/            # Environment-specific configs
├── infrastructure/          # AWS infrastructure components
└── observability/          # Monitoring stack
```

## 🚀 **Quick Deployment**

### **Production Deployment** (Currently Active)
```bash
# Deploy core application
kubectl apply -f ./k8s/base/

# Deploy production ingress (AWS ALB)
kubectl apply -f ./k8s/environments/production/

# Verify deployment
kubectl get deployments,services,ingress
```

### **Development Deployment**
```bash
# Deploy core application
kubectl apply -f ./k8s/base/

# Deploy development ingress (NGINX)
kubectl apply -f ./k8s/environments/development/
```

### **Staging Deployment**
```bash
# Deploy core application
kubectl apply -f ./k8s/base/

# Deploy staging ingress
kubectl apply -f ./k8s/environments/staging/
```

## 📋 **File Descriptions**

### **Base Applications** (`./base/`)
- `backend-deployment.yaml` - Backend deployment, service, secrets, configmap
- `frontend-deployment.yaml` - Frontend deployment and service

### **Environment Configurations** (`./environments/`)
- `development/ingress-development.yaml` - NGINX ingress for local dev
- `staging/ingress-staging.yaml` - NGINX ingress for staging
- `production/ingress-production.yaml` - AWS ALB ingress (ACTIVE)

### **Infrastructure** (`./infrastructure/`)
- `aws-load-balancer-controller-sa.yaml` - ALB controller service account
- `iam-setup.yaml` - IAM roles and policies

### **Observability** (`./observability/`)
- `prometheus-deployment.yaml` - Metrics collection
- `grafana-deployment.yaml` - Visualization dashboard
- `prometheus-config.yaml` - Prometheus configuration

## ✅ **Current Active Resources**

| Resource | File | Status |
|----------|------|---------|
| Backend Deployment | `base/backend-deployment.yaml` | ✅ **RUNNING** |
| Frontend Deployment | `base/frontend-deployment.yaml` | ✅ **RUNNING** |
| Production Ingress | `environments/production/ingress-production.yaml` | ✅ **ACTIVE** |

## 🔧 **Maintenance Commands**

```bash
# Update application
kubectl apply -f ./k8s/base/

# Switch environments
kubectl delete ingress --all
kubectl apply -f ./k8s/environments/{environment}/

# Deploy monitoring
kubectl apply -f ./k8s/observability/

# Check status
kubectl get all
```
