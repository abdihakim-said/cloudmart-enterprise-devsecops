# CloudMart Troubleshooting Guide

## 🔧 **Common Issues & Solutions**

### **Infrastructure Issues**

#### Terraform Apply Fails
```bash
# Issue: Terraform state lock
Error: Error acquiring the state lock

# Solution: Force unlock (use with caution)
terraform force-unlock <lock-id>

# Prevention: Always use terraform in CI/CD
```

#### EKS Cluster Access Denied
```bash
# Issue: Cannot access EKS cluster
error: You must be logged in to the server (Unauthorized)

# Solution: Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name cloudmart-cluster

# Verify access
kubectl get nodes
```

### **Application Issues**

#### Pods Stuck in Pending State
```bash
# Check node capacity
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name>

# Common causes:
# - Insufficient resources
# - Image pull errors
# - Node selector issues
```

#### Database Connection Errors
```bash
# Check DynamoDB table status
aws dynamodb describe-table --table-name cloudmart-products

# Verify IAM permissions
aws sts get-caller-identity

# Check service account annotations
kubectl describe serviceaccount cloudmart-backend-sa
```

### **Security Issues**

#### Security Scans Failing
```bash
# Trivy scan fails
# Solution: Update base images
docker pull node:20-alpine

# Semgrep issues
# Solution: Review and fix code patterns
```

#### Secrets Not Loading
```bash
# Check AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id cloudmart/api-keys

# Verify IRSA configuration
kubectl describe serviceaccount cloudmart-backend-sa
```

### **Monitoring Issues**

#### Prometheus Not Scraping Metrics
```bash
# Check service discovery
kubectl get endpoints -n monitoring

# Verify pod annotations
kubectl describe pod <app-pod> | grep prometheus.io

# Check Prometheus targets
# Access Prometheus UI → Status → Targets
```

#### Grafana Dashboard Not Loading
```bash
# Check Grafana logs
kubectl logs -f deployment/grafana -n monitoring

# Verify data source connection
# Grafana → Configuration → Data Sources → Test
```

## 🚨 **Emergency Procedures**

### **Application Rollback**
```bash
# Rollback deployment
kubectl rollout undo deployment/cloudmart-frontend
kubectl rollout undo deployment/cloudmart-backend

# Check rollout status
kubectl rollout status deployment/cloudmart-frontend
```

### **Infrastructure Rollback**
```bash
# Terraform rollback
terraform plan -destroy
terraform apply -auto-approve

# Or restore from backup
terraform import <resource> <id>
```

## 📊 **Diagnostic Commands**

### **Cluster Health**
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces

# Check resource usage
kubectl top nodes
kubectl top pods
```

### **Application Logs**
```bash
# Application logs
kubectl logs -f deployment/cloudmart-frontend
kubectl logs -f deployment/cloudmart-backend

# Previous container logs
kubectl logs <pod-name> --previous
```

### **Network Diagnostics**
```bash
# Test connectivity
kubectl exec -it <pod-name> -- nslookup kubernetes.default

# Check network policies
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>
```

## 📞 **Getting Help**

1. Check this troubleshooting guide
2. Review application logs
3. Check monitoring dashboards
4. Consult team documentation
5. Escalate to DevOps team
