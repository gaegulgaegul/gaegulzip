# Stage 1: Install all dependencies
FROM node:20-alpine AS deps

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.27.0 --activate

WORKDIR /app

# Copy dependency files
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies for build)
RUN pnpm install --frozen-lockfile

# Stage 2: Build TypeScript
FROM node:20-alpine AS build

RUN corepack enable && corepack prepare pnpm@10.27.0 --activate

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json

# Copy source code and config
COPY tsconfig.json ./
COPY src ./src
COPY docs ./docs
COPY drizzle ./drizzle
COPY drizzle.config.ts ./

# Build TypeScript
RUN pnpm build

# Stage 3: Production runtime
FROM node:20-alpine AS production

RUN corepack enable && corepack prepare pnpm@10.27.0 --activate

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Copy built application from build stage
COPY --from=build /app/dist ./dist
COPY --from=build /app/docs ./docs
COPY --from=build /app/drizzle ./drizzle

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "dist/server.js"]
