# 🎯 DevSecOps Interview Scenarios & Solutions

## **Real Production Scenarios from CloudMart Project**

---

## **1. EKS kubectl Authentication Failure**

### **Scenario:**
```
Pipeline fails with: "error: You must be logged in to the server (the server has asked for the client to provide credentials)"
```

### **Root Cause Analysis:**
- EKS cluster exists and is ACTIVE
- IAM user has AWS permissions but not Kubernetes permissions
- aws-auth ConfigMap doesn't include CI/CD IAM user

### **Solution:**
```bash
# 1. Identify the IAM user being used
aws sts get-caller-identity

# 2. Update aws-auth ConfigMap
kubectl patch configmap aws-auth -n kube-system --patch '
data:
  mapUsers: |
    - userarn: arn:aws:iam::ACCOUNT:user/cloudmart-cicd
      username: cloudmart-cicd
      groups:
      - system:masters'

# 3. Verify update
kubectl get configmap aws-auth -n kube-system -o yaml
```

### **Interview Answer:**
*"This is an EKS authentication issue. EKS uses IAM for authentication but Kubernetes RBAC for authorization. The CI/CD IAM user needs to be mapped in the aws-auth ConfigMap. I would add the user with appropriate permissions and verify the mapping."*

---

## **2. Semgrep Security Scan Blocking Pipeline**

### **Scenario:**
```
CI scan completed successfully.
Found 79 findings (79 blocking) from 1062 rules.
Has findings for blocking rules so exiting with code 1
```

### **Root Cause Analysis:**
- Security scanner finding infrastructure warnings
- Mix of real vulnerabilities and false positives
- Need to distinguish critical vs. acceptable risks

### **Solution:**
```bash
# 1. Fix critical security issues first
# - Add EKS control plane logging
# - Enable Lambda X-Ray tracing
# - Fix dependency vulnerabilities

# 2. Create targeted suppressions
echo "terraform/modules/" >> .semgrepignore
echo "scripts/" >> .semgrepignore

# 3. Document business justification
# AWS managed encryption acceptable for demo environment
```

### **Interview Answer:**
*"I'd first fix genuine security issues like missing logging and vulnerable dependencies. Then create targeted suppressions for infrastructure warnings that are acceptable business risks, with proper documentation. The goal is security without blocking legitimate deployments."*

---

## **3. ECR Image Reference Issues**

### **Scenario:**
```
sed -i "s|ECR_REPOSITORY_URI||g" k8s/base/backend-deployment.yaml
# Results in invalid image reference: :backend-sha123
```

### **Root Cause Analysis:**
- ECR_REPOSITORY_URI secret is empty or not set
- Pipeline job doesn't have access to ECR login outputs
- Kubernetes deployment needs full image path

### **Solution:**
```yaml
# 1. Add ECR login to deployment job
- name: Login to Amazon ECR
  id: login-ecr
  uses: aws-actions/amazon-ecr-login@v2

# 2. Use computed ECR URI
sed -i "s|ECR_REPOSITORY_URI|${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}|g"

# 3. Update Kubernetes manifests with placeholders
image: ECR_REPOSITORY_URI:IMAGE_TAG
```

### **Interview Answer:**
*"The issue is that the deployment job needs access to the ECR registry URI. I'd add ECR login to the deployment job and use the computed registry output instead of relying on secrets. This ensures the full image path is correctly substituted."*

---

## **4. npm Audit Vulnerabilities Blocking Build**

### **Scenario:**
```
11 vulnerabilities (3 low, 4 moderate, 3 high, 1 critical)
Error: Process completed with exit code 1
```

### **Root Cause Analysis:**
- Dependencies have known security vulnerabilities
- Critical vulnerabilities must be fixed before deployment
- Some fixes may require breaking changes

### **Solution:**
```bash
# 1. Fix automatically resolvable issues
npm audit fix

# 2. Force fix breaking changes if necessary
npm audit fix --force

# 3. Verify no vulnerabilities remain
npm audit

# 4. Test application still works after updates
npm test && npm run build
```

### **Interview Answer:**
*"I'd run npm audit fix to resolve automatically fixable vulnerabilities. For breaking changes, I'd evaluate the security risk vs. functionality impact. Critical vulnerabilities require immediate fixing, even if it means accepting breaking changes and updating code accordingly."*

---

## **5. GitHub SARIF Upload Permission Errors**

### **Scenario:**
```
Warning: Resource not accessible by integration
Error: Resource not accessible by integration
```

### **Root Cause Analysis:**
- GitHub workflow lacks security-events write permission
- SARIF upload fails, blocking pipeline progression
- Security scan results can't be uploaded to Security tab

### **Solution:**
```yaml
# Add required permissions to workflow
permissions:
  contents: read
  security-events: write
  actions: read
```

### **Interview Answer:**
*"This is a GitHub Actions permissions issue. The workflow needs security-events write permission to upload SARIF results to the Security tab. I'd add the required permissions block to enable proper security integration."*

---

## **6. Pipeline Triggering on Wrong File Changes**

### **Scenario:**
```
# Pipeline doesn't trigger when changing .semgrepignore
# Only triggers on frontend/**, backend/**, k8s/base/**
```

### **Root Cause Analysis:**
- Pipeline paths configuration excludes certain files
- .semgrepignore changes don't trigger application pipeline
- Need to understand trigger vs. scan scope

### **Solution:**
```yaml
# Application pipeline triggers
on:
  push:
    paths:
      - 'frontend/**'
      - 'backend/**' 
      - 'k8s/base/**'

# Infrastructure pipeline triggers  
on:
  push:
    paths:
      - 'terraform/**'
```

### **Interview Answer:**
*"Pipeline triggers are path-based. The application pipeline only triggers on app-related changes, while infrastructure changes trigger the infrastructure pipeline. This separation prevents unnecessary builds and follows GitOps principles."*

---

## **7. Docker Build Context Issues**

### **Scenario:**
```
# Pipeline builds in wrong directory
cd backend && docker build -t image .
# vs
docker build -f backend/Dockerfile -t image backend/
```

### **Root Cause Analysis:**
- Docker build context affects file access
- Dockerfile location vs. build context directory
- Pipeline working directory considerations

### **Solution:**
```bash
# Correct approach - change to app directory
cd backend
docker build -t $ECR_URI:backend-$SHA .

# Alternative - specify context and dockerfile
docker build -f backend/Dockerfile -t $ECR_URI:backend-$SHA backend/
```

### **Interview Answer:**
*"Docker build context determines which files are available during build. I'd ensure the pipeline changes to the correct directory before building, or specify both the Dockerfile path and build context explicitly."*

---

## **8. Kubernetes Deployment File Path Mismatches**

### **Scenario:**
```
sed: can't read k8s/app/backend-deployment.yaml: No such file or directory
# Files are actually in k8s/base/
```

### **Root Cause Analysis:**
- Pipeline references wrong directory structure
- Kubernetes manifests organized differently than expected
- Need to align pipeline with actual file structure

### **Solution:**
```bash
# 1. Check actual file structure
ls -la k8s/

# 2. Update pipeline paths
sed -i "s|IMAGE_TAG|backend-$SHA|g" k8s/base/backend-deployment.yaml

# 3. Update trigger paths
paths:
  - 'k8s/base/**'
```

### **Interview Answer:**
*"This is a path mismatch between pipeline expectations and actual file structure. I'd verify the correct directory structure and update the pipeline to reference the actual file locations."*

---

## **9. Multi-Stage Pipeline Job Dependencies**

### **Scenario:**
```
# Deploy job can't access build job outputs
${{ steps.login-ecr.outputs.registry }} # Empty in deploy job
```

### **Root Cause Analysis:**
- GitHub Actions jobs run in isolation
- Step outputs don't cross job boundaries
- Need to recreate resources or pass data between jobs

### **Solution:**
```yaml
# Option 1: Add ECR login to deploy job
deploy:
  steps:
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v2

# Option 2: Pass data via job outputs
build:
  outputs:
    ecr-registry: ${{ steps.login-ecr.outputs.registry }}
deploy:
  needs: build
  steps:
    - name: Use ECR registry
      run: echo ${{ needs.build.outputs.ecr-registry }}
```

### **Interview Answer:**
*"GitHub Actions jobs are isolated. I'd either recreate the ECR login in the deploy job or use job outputs to pass data between jobs. The first approach is simpler for this use case."*

---

## **10. AWS IAM Permission Boundaries**

### **Scenario:**
```
# IAM user has AWS permissions but not EKS access
aws eks describe-cluster --name cluster # Works
kubectl get pods # Fails
```

### **Root Cause Analysis:**
- AWS IAM vs. Kubernetes RBAC are separate systems
- EKS uses aws-auth ConfigMap for user mapping
- Need both AWS and Kubernetes permissions

### **Solution:**
```bash
# 1. Verify IAM user exists
aws iam get-user --user-name cloudmart-cicd

# 2. Add to EKS aws-auth ConfigMap
kubectl patch configmap aws-auth -n kube-system --patch '
data:
  mapUsers: |
    - userarn: arn:aws:iam::ACCOUNT:user/cloudmart-cicd
      username: cloudmart-cicd
      groups:
      - system:masters'
```

### **Interview Answer:**
*"EKS authentication involves both AWS IAM and Kubernetes RBAC. The IAM user needs AWS permissions to call EKS APIs, but also needs to be mapped in the aws-auth ConfigMap to get Kubernetes permissions."*

---

## **11. Container Security Scanning Integration**

### **Scenario:**
```
# Trivy scan passes but images have vulnerabilities
# Need to integrate security scanning into pipeline
```

### **Root Cause Analysis:**
- Security scanning not properly integrated
- Vulnerabilities not blocking deployment
- Need automated security gates

### **Solution:**
```yaml
- name: Container Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.ECR_URI }}:${{ github.sha }}
    format: 'sarif'
    output: 'trivy-results.sarif'
    exit-code: '1' # Fail on vulnerabilities
    severity: 'CRITICAL,HIGH'
```

### **Interview Answer:**
*"I'd integrate Trivy scanning with exit codes to fail the pipeline on critical/high vulnerabilities. This creates an automated security gate that prevents vulnerable images from reaching production."*

---

## **12. Rollback Strategy Implementation**

### **Scenario:**
```
# Deployment causes production issues
# Need immediate rollback capability
```

### **Root Cause Analysis:**
- No automated rollback mechanism
- Need multiple rollback strategies
- Recovery time objectives not met

### **Solution:**
```bash
# 1. Kubernetes rolling rollback (fastest)
kubectl rollout undo deployment/app

# 2. Git-based rollback
git revert HEAD && git push

# 3. Manual image rollback
kubectl set image deployment/app container=ECR_URI:previous-tag

# 4. Blue-green deployment
# Switch traffic back to previous version
```

### **Interview Answer:**
*"I'd implement multiple rollback strategies: Kubernetes rolling rollback for immediate issues, Git revert for code-level rollbacks, and blue-green deployments for zero-downtime rollbacks. The choice depends on the issue type and recovery time requirements."*

---

## **13. Secret Management in CI/CD**

### **Scenario:**
```
# Secrets exposed in logs or configuration
# Need secure secret handling
```

### **Root Cause Analysis:**
- Secrets hardcoded in configuration
- Improper secret injection methods
- Lack of secret rotation

### **Solution:**
```yaml
# 1. Use GitHub Secrets
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}

# 2. AWS Secrets Manager integration
- name: Get secrets
  run: |
    SECRET=$(aws secretsmanager get-secret-value --secret-id prod/app/config)
    echo "::add-mask::$SECRET"

# 3. Kubernetes secrets
kubectl create secret generic app-secrets --from-literal=key=value
```

### **Interview Answer:**
*"I'd use GitHub Secrets for CI/CD credentials, AWS Secrets Manager for application secrets, and Kubernetes secrets for runtime configuration. All secrets should be masked in logs and rotated regularly."*

---

## **14. Multi-Cloud Deployment Coordination**

### **Scenario:**
```
# Deploy to AWS EKS, integrate with Azure AI, sync to GCP BigQuery
# Need coordinated multi-cloud deployment
```

### **Root Cause Analysis:**
- Services span multiple cloud providers
- Need coordinated deployment strategy
- Cross-cloud authentication and networking

### **Solution:**
```yaml
# 1. Separate deployment jobs per cloud
deploy-aws:
  steps:
    - name: Deploy to EKS
deploy-azure:
  needs: deploy-aws
  steps:
    - name: Configure Azure AI
deploy-gcp:
  needs: deploy-aws
  steps:
    - name: Setup BigQuery pipeline
```

### **Interview Answer:**
*"I'd create separate deployment jobs for each cloud provider with proper dependencies. AWS would be the primary deployment, followed by Azure and GCP configuration. Each job would handle cloud-specific authentication and resource management."*

---

## **15. Performance Testing Integration**

### **Scenario:**
```
# Need automated performance testing in pipeline
# Prevent performance regressions
```

### **Root Cause Analysis:**
- No performance validation in CI/CD
- Performance regressions reach production
- Need automated performance gates

### **Solution:**
```yaml
- name: Performance Testing
  run: |
    # Load testing with k6
    k6 run --vus 100 --duration 30s performance-test.js
    
    # Response time validation
    RESPONSE_TIME=$(curl -w "%{time_total}" -s -o /dev/null $APP_URL)
    if (( $(echo "$RESPONSE_TIME > 0.5" | bc -l) )); then
      echo "Performance regression detected"
      exit 1
    fi
```

### **Interview Answer:**
*"I'd integrate k6 or similar tools for load testing, with automated gates for response time and throughput. Performance tests would run after deployment to staging, with failures blocking production promotion."*

---

## **16. Infrastructure Drift Detection**

### **Scenario:**
```
# Manual changes made to infrastructure
# Terraform state out of sync with reality
```

### **Root Cause Analysis:**
- Manual changes bypass Terraform
- Infrastructure drift not detected
- Need automated drift detection

### **Solution:**
```bash
# 1. Scheduled drift detection
terraform plan -detailed-exitcode
if [ $? -eq 2 ]; then
  echo "Infrastructure drift detected"
  # Send alert or create issue
fi

# 2. Prevent manual changes
# Use IAM policies to restrict console access
# Enable CloudTrail for audit logging
```

### **Interview Answer:**
*"I'd implement scheduled Terraform plan runs to detect drift, with alerts for any changes. I'd also use IAM policies to prevent manual changes and CloudTrail for audit logging. All infrastructure changes should go through the GitOps pipeline."*

---

## **17. Compliance Automation**

### **Scenario:**
```
# Need SOC 2 compliance evidence
# Automated compliance reporting required
```

### **Root Cause Analysis:**
- Manual compliance processes
- Lack of automated evidence collection
- Audit trail gaps

### **Solution:**
```yaml
- name: Compliance Checks
  run: |
    # Security scanning evidence
    semgrep --config=auto --sarif > security-scan.sarif
    
    # Access control validation
    kubectl auth can-i --list --as=system:serviceaccount:default:app
    
    # Encryption validation
    aws kms describe-key --key-id $KMS_KEY_ID
    
    # Store evidence in compliance bucket
    aws s3 cp compliance-evidence/ s3://compliance-bucket/$(date +%Y-%m-%d)/
```

### **Interview Answer:**
*"I'd automate compliance evidence collection through the CI/CD pipeline, storing security scan results, access control matrices, and encryption validation in a compliance bucket. This provides auditors with timestamped evidence of continuous compliance."*

---

## **18. Disaster Recovery Testing**

### **Scenario:**
```
# Need to validate disaster recovery procedures
# Automated DR testing required
```

### **Root Cause Analysis:**
- DR procedures not regularly tested
- Manual DR processes prone to errors
- RTO/RPO objectives not validated

### **Solution:**
```bash
# 1. Automated backup validation
aws rds describe-db-snapshots --db-instance-identifier prod-db
kubectl get volumesnapshots

# 2. Cross-region deployment test
terraform apply -var="region=us-west-2" -var="environment=dr-test"

# 3. Data recovery validation
# Restore from backup and validate data integrity
```

### **Interview Answer:**
*"I'd implement automated DR testing with scheduled backup validation, cross-region deployment tests, and data integrity checks. This ensures our RTO/RPO objectives are met and DR procedures work when needed."*

---

## **🎯 Interview Success Framework**

### **Problem-Solving Approach:**
1. **Identify** the root cause (not just symptoms)
2. **Analyze** the impact and urgency
3. **Propose** multiple solution options
4. **Implement** with proper testing
5. **Document** for future reference
6. **Monitor** to prevent recurrence

### **Key Phrases for Interviews:**
- *"Let me analyze the root cause..."*
- *"I would implement multiple approaches..."*
- *"This demonstrates production-ready thinking..."*
- *"From a security perspective..."*
- *"Considering the business impact..."*
- *"Following industry best practices..."*

### **Technical Depth Indicators:**
- Explain **why** not just **what**
- Discuss **trade-offs** and alternatives
- Show **security-first** thinking
- Demonstrate **automation** mindset
- Exhibit **monitoring** and **observability** focus

---

## **🚀 Confidence Builders**

**Remember:** You've solved real production issues in this project. You have hands-on experience with:
- EKS authentication and RBAC
- Multi-stage CI/CD pipelines
- Security scanning integration
- Container orchestration
- Multi-cloud architecture
- Infrastructure as Code
- Monitoring and observability

**You're ready for senior DevSecOps roles!** 🎯
