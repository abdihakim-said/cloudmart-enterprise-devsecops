# Multi-stage build for security and optimization
FROM node:20-alpine AS builder

# Security: Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Production stage
FROM node:20-alpine AS runner

# Security: Install security updates and dumb-init
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init curl && \
    rm -rf /var/cache/apk/*

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001

WORKDIR /app

# Security: Copy application with proper ownership
COPY --from=builder --chown=nodeuser:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodeuser:nodejs /app/src ./src
COPY --from=builder --chown=nodeuser:nodejs /app/package.json ./package.json

# Security: Switch to non-root user
USER nodeuser

# Security: Expose port (non-privileged)
EXPOSE 5000

# Security: Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Environment variables
ENV NODE_ENV=production
ENV PORT=5000

# Security: Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["node", "src/server.js"]

# Security labels
LABEL maintainer="cloudmart-devops@example.com" \
      version="1.0.0" \
      description="CloudMart Backend - Secure Production Build" \
      security.scan="trivy,snyk" \
      org.opencontainers.image.source="https://github.com/your-org/cloudmart"
