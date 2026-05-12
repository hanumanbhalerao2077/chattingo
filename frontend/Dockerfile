# ============================================
# Stage 1: Build the React application
# ============================================
FROM node:18.18.2-alpine AS builder

WORKDIR /build

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the application
RUN npm run build

# ============================================
# Stage 2: Serve the application with nginx
# ============================================
FROM nginx:1.25.3-alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy built React app from builder
COPY --from=builder /build/build /usr/share/nginx/html

# Create a non-root user (nginx already runs as non-root by default)
RUN chmod -R 755 /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/index.html || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
