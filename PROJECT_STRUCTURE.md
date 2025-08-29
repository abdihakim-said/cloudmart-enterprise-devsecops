# CloudMart Project Structure

## 📁 **Organized File Structure**

```
cloudmart-project/
├── 📄 README.md                          # Project overview
├── 📄 LICENSE                            # MIT License
├── 📄 PROJECT_STRUCTURE.md               # This file
├── 📄 CHANGELOG.md                       # Version history
├── 📄 CONTRIBUTING.md                    # Contribution guidelines
│
├── 📁 docs/                              # Documentation
│   ├── 📁 deployment/                    # Deployment guides
│   │   ├── 📄 DEPLOYMENT_CHALLENGES.md   # Challenges & solutions
│   │   ├── 📄 RESOURCE_STATE_VERIFICATION.md # Resource sync status
│   │   └── 📄 INGRESS_ENVIRONMENTS.md    # Ingress configuration guide
│   ├── 📁 architecture/                  # Architecture documentation
│   ├── 📁 diagrams/                      # Architecture diagrams
│   ├── 📁 ADR/                          # Architecture Decision Records
│   └── 📁 runbooks/                     # Operational guides
│
├── 📁 k8s/                              # Kubernetes configurations
│   ├── 📁 base/                         # Base application manifests
│   │   ├── 📄 backend-deployment.yaml    # Backend deployment (ACTIVE)
│   │   └── 📄 frontend-deployment.yaml   # Frontend deployment (ACTIVE)
│   │
│   ├── 📁 environments/                 # Environment-specific configs
│   │   ├── 📁 development/              # Development environment
│   │   │   └── 📄 ingress-development.yaml # NGINX ingress for dev
│   │   ├── 📁 staging/                  # Staging environment
│   │   │   └── 📄 ingress-staging.yaml  # NGINX ingress for staging
│   │   └── 📁 production/               # Production environment
│   │       └── 📄 ingress-production.yaml # AWS ALB ingress (ACTIVE)
│   │
│   ├── 📁 infrastructure/               # Infrastructure components
│   │   ├── 📄 aws-load-balancer-controller-sa.yaml # ALB controller
│   │   └── 📄 iam-setup.yaml            # IAM configurations
│   │
│   └── 📁 observability/                # Monitoring stack
│       ├── 📄 prometheus-deployment.yaml # Metrics collection
│       ├── 📄 grafana-deployment.yaml   # Visualization
│       ├── 📄 prometheus-config.yaml    # Prometheus config
│       ├── 📄 node-exporter.yaml        # Node metrics
│       └── 📄 rbac.yaml                 # Monitoring RBAC
│
├── 📁 terraform/                        # Infrastructure as Code
│   ├── 📄 main.tf                       # Main configuration
│   ├── 📄 variables.tf                  # Input variables
│   ├── 📄 outputs.tf                    # Output values
│   └── 📁 modules/                      # Terraform modules
│       ├── 📁 networking/               # VPC, subnets
│       ├── 📁 eks/                      # EKS cluster
│       ├── 📁 database/                 # DynamoDB
│       └── 📁 lambda/                   # Serverless functions
│
├── 📁 frontend/                         # React application
│   ├── 📄 package.json                  # Dependencies
│   ├── 📄 Dockerfile                    # Container build
│   ├── 📁 src/                          # Source code
│   └── 📁 tests/                        # Frontend tests
│
├── 📁 backend/                          # Node.js API
│   ├── 📄 package.json                  # Dependencies
│   ├── 📄 Dockerfile                    # Container build
│   ├── 📁 src/                          # Source code
│   └── 📁 tests/                        # Backend tests
│
├── 📁 scripts/                          # Automation scripts
│   ├── 📄 setup-environment.sh          # Environment setup
│   ├── 📄 deploy-observability.sh       # Monitoring deployment
│   └── 📄 build-and-push.sh             # Container automation
│
├── 📁 config/                           # Configuration files
│   ├── 📁 environments/                 # Environment configs
│   └── 📄 docker-compose.yml            # Local development
│
├── 📁 tests/                            # Testing suite
│   ├── 📁 integration/                  # Integration tests
│   ├── 📁 e2e/                         # End-to-end tests
│   └── 📁 security/                    # Security tests
│
├── 📁 monitoring/                       # Monitoring configurations
│   ├── 📁 grafana/                     # Dashboards
│   ├── 📁 prometheus/                  # Metrics config
│   └── 📁 alertmanager/                # Alert routing
│
├── 📁 security/                         # Security configurations
│   ├── 📄 falco-rules.yaml             # Runtime security
│   ├── 📁 k8s/                         # Security policies
│   └── 📁 policies/                    # Security policies
│
├── 📁 tools/                           # Development tools
│   ├── 📁 local-development/           # Local dev setup
│   └── 📁 ci-cd/                       # CI/CD utilities
│
└── 📁 backup-unused-files/             # Cleaned up files
    ├── 📄 README.md                     # Cleanup documentation
    ├── 📄 cloudmart-backend-duplicate.yaml
    ├── 📄 cloudmart-frontend-duplicate.yaml
    └── 📄 frontend-simple-duplicate.yaml
```

## 🎯 **Key Organization Principles**

### **1. Environment Separation**
- **Development**: Local/testing configurations
- **Staging**: Pre-production testing
- **Production**: Live environment (currently active)

### **2. Base vs Environment-Specific**
- **Base**: Core application deployments (environment-agnostic)
- **Environments**: Environment-specific configurations (ingress, secrets)

### **3. Infrastructure vs Application**
- **Infrastructure**: AWS resources, IAM, load balancers
- **Application**: Deployments, services, application configs

### **4. Documentation Organization**
- **Deployment**: Operational guides and troubleshooting
- **Architecture**: Design decisions and diagrams
- **Runbooks**: Step-by-step operational procedures

## 🚀 **Deployment Commands by Environment**

### **Development**
```bash
# Deploy base application
kubectl apply -f ./k8s/base/

# Deploy development ingress
kubectl apply -f ./k8s/environments/development/
```

### **Staging**
```bash
# Deploy base application
kubectl apply -f ./k8s/base/

# Deploy staging ingress
kubectl apply -f ./k8s/environments/staging/
```

### **Production** (Currently Active)
```bash
# Deploy base application
kubectl apply -f ./k8s/base/

# Deploy production ingress
kubectl apply -f ./k8s/environments/production/

# Deploy infrastructure (if needed)
kubectl apply -f ./k8s/infrastructure/
```

### **Monitoring Stack**
```bash
# Deploy observability
kubectl apply -f ./k8s/observability/
```

## 📋 **File Status Legend**

- ✅ **ACTIVE**: Currently deployed and running
- 📝 **READY**: Configured but not deployed
- 🗂️ **BACKUP**: Moved to backup (duplicates/unused)
- 📚 **DOCS**: Documentation and guides

## 🎯 **Benefits of This Organization**

1. **Clear Separation**: Environment-specific vs base configurations
2. **Easy Deployment**: Simple commands for each environment
3. **Scalable**: Easy to add new environments
4. **Professional**: Industry-standard project structure
5. **Maintainable**: Clear file purposes and locations
6. **Team-Friendly**: Easy for new team members to understand

This structure follows Kubernetes and DevOps best practices for enterprise applications.
