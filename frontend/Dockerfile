# Multi-stage build for security and optimization
FROM node:20-alpine AS builder

# Security: Install security updates and required packages
RUN apk update && apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001

# Security: Set working directory
WORKDIR /app

# Security: Copy package files first for better caching
COPY package*.json ./

# Security: Install dependencies with npm ci for reproducible builds
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

# Security: Install security updates and dumb-init
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init curl && \
    rm -rf /var/cache/apk/*

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001

WORKDIR /app

# Install serve globally
RUN npm install -g serve

# Security: Copy built application with proper ownership
COPY --from=builder --chown=reactuser:nodejs /app/dist ./

# Security: Switch to non-root user
USER reactuser

# Security: Expose port (non-privileged)
EXPOSE 3000

# Security: Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Environment variables
ENV PORT=3000
ENV NODE_ENV=production

# Security: Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["serve", "-s", ".", "-l", "3000"]

# Security labels
LABEL maintainer="cloudmart-devops@example.com" \
      version="1.0.0" \
      description="CloudMart Frontend - Secure Production Build" \
      security.scan="trivy,snyk" \
      org.opencontainers.image.source="https://github.com/your-org/cloudmart"

