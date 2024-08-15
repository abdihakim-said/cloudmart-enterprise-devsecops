# Contributing to CloudMart

Thank you for your interest in contributing to CloudMart! This document provides guidelines and information for contributors.

## 🎯 **Code of Conduct**

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [abdihakimsaid1@gmail.com](mailto:abdihakimsaid1@gmail.com).

## 🚀 **Getting Started**

### Prerequisites
- Node.js 20+
- Docker 24+
- Kubernetes 1.28+
- Terraform 1.6+
- AWS CLI 2.0+

### Development Setup
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/cloudmart-enterprise-devsecops.git
cd cloudmart-enterprise-devsecops

# Install dependencies
cd frontend && npm install
cd ../backend && npm install

# Set up pre-commit hooks
npm install -g husky
husky install
```

## 🔄 **Development Workflow**

### 1. Fork and Clone
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/cloudmart-enterprise-devsecops.git
cd cloudmart-enterprise-devsecops

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/cloudmart-enterprise-devsecops.git
```

### 2. Create Feature Branch
```bash
# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 3. Make Changes
- Follow the coding standards
- Write tests for new functionality
- Update documentation as needed
- Ensure security best practices

### 4. Test Your Changes
```bash
# Run frontend tests
cd frontend && npm test

# Run backend tests
cd backend && npm test

# Run security scans
npm run security:scan

# Test Docker builds
docker build -t cloudmart-frontend:test frontend/
docker build -t cloudmart-backend:test backend/
```

### 5. Commit Changes
```bash
# Stage changes
git add .

# Commit with conventional commit format
git commit -m "feat: add new feature description"
git commit -m "fix: resolve bug description"
git commit -m "docs: update documentation"
```

### 6. Push and Create PR
```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
```

## 📝 **Commit Message Convention**

We use [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `security`: Security improvements
- `perf`: Performance improvements

### Examples
```bash
feat(auth): add OAuth2 integration
fix(api): resolve memory leak in user service
docs(readme): update installation instructions
security(deps): update vulnerable dependencies
```

## 🧪 **Testing Guidelines**

### Unit Tests
- Write unit tests for all new functions
- Maintain minimum 80% code coverage
- Use Jest for JavaScript testing

### Integration Tests
- Test API endpoints thoroughly
- Test database interactions
- Test external service integrations

### Security Tests
- All code must pass security scans
- No hardcoded secrets or credentials
- Follow OWASP security guidelines

### Performance Tests
- Load test critical endpoints
- Monitor memory usage
- Optimize database queries

## 🔒 **Security Guidelines**

### Code Security
- Never commit secrets or credentials
- Use environment variables for configuration
- Validate all user inputs
- Implement proper authentication/authorization

### Infrastructure Security
- Follow AWS security best practices
- Use least privilege IAM policies
- Enable encryption at rest and in transit
- Implement network security groups

### Container Security
- Use minimal base images
- Run containers as non-root user
- Scan images for vulnerabilities
- Keep dependencies updated

## 📊 **Code Quality Standards**

### JavaScript/TypeScript
```javascript
// Use ESLint and Prettier
// Follow Airbnb style guide
// Use meaningful variable names
// Add JSDoc comments for functions

/**
 * Processes user orders and updates inventory
 * @param {Object} order - The order object
 * @param {string} userId - The user identifier
 * @returns {Promise<Object>} Processed order result
 */
async function processOrder(order, userId) {
  // Implementation
}
```

### Terraform
```hcl
# Use consistent naming conventions
# Add descriptions to variables
# Use tags for all resources
# Follow module structure

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "Cluster name cannot be empty."
  }
}
```

### Kubernetes
```yaml
# Use resource limits
# Add labels and annotations
# Follow security best practices
# Use namespaces appropriately

apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudmart-frontend
  labels:
    app: cloudmart-frontend
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cloudmart-frontend
```

## 📚 **Documentation Standards**

### Code Documentation
- Add JSDoc comments for all functions
- Document complex algorithms
- Explain business logic
- Include usage examples

### API Documentation
- Use OpenAPI/Swagger specifications
- Document all endpoints
- Include request/response examples
- Document error codes

### Infrastructure Documentation
- Document architecture decisions
- Create deployment guides
- Maintain runbooks
- Update troubleshooting guides

## 🐛 **Bug Reports**

When reporting bugs, please include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Screenshots if applicable
- Relevant logs

## ✨ **Feature Requests**

When requesting features, please include:
- Problem statement
- Proposed solution
- Business value
- Technical considerations
- Acceptance criteria

## 🔍 **Code Review Process**

### For Contributors
- Ensure all tests pass
- Update documentation
- Follow coding standards
- Address reviewer feedback promptly

### For Reviewers
- Review for functionality
- Check security implications
- Verify test coverage
- Ensure documentation updates

### Review Checklist
- [ ] Code follows project standards
- [ ] Tests are comprehensive
- [ ] Security considerations addressed
- [ ] Documentation updated
- [ ] Performance impact considered
- [ ] Breaking changes documented

## 🚀 **Release Process**

### Version Numbering
We follow [Semantic Versioning](https://semver.org/):
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Steps
1. Update version numbers
2. Update CHANGELOG.md
3. Create release branch
4. Run full test suite
5. Deploy to staging
6. Create GitHub release
7. Deploy to production

## 📞 **Getting Help**

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Email**: [abdihakimsaid1@gmail.com](mailto:abdihakimsaid1@gmail.com)

### Resources
- [Project Documentation](docs/)
- [Architecture Guide](docs/ARCHITECTURE.md)
- [Security Guide](docs/SECURITY.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🏆 **Recognition**

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation
- LinkedIn recommendations (upon request)

## 📄 **License**

By contributing to CloudMart, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to CloudMart! Your efforts help make this project better for everyone. 🚀
