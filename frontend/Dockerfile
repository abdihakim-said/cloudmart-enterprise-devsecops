# Build stage
FROM node:18-alpine as build

# Install security updates
RUN apk update && apk upgrade && rm -rf /var/cache/apk/*

WORKDIR /app

# Copy package files first for better layer caching
COPY package*.json ./

# Use npm ci for reproducible builds
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Set API URL for production build
ENV VITE_API_BASE_URL=/api

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine

# Install security updates and create non-root user
RUN apk update && apk upgrade && rm -rf /var/cache/apk/* && \
    addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

WORKDIR /app

# Install serve globally
RUN npm install -g serve

# Copy built files with proper ownership
COPY --from=build --chown=appuser:appgroup /app/dist /app

# Switch to non-root user
USER appuser

# Environment variables
ENV PORT=5001
ENV NODE_ENV=production

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5001/ || exit 1

# Start application
CMD ["serve", "-s", ".", "-l", "5001"]
