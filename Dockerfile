#FROM node:18-alpine AS base
FROM public.ecr.aws/docker/library/node:20.14.0-alpine3.20 AS base
 
FROM base AS builder
RUN apk add --no-cache libc6-compat
RUN apk update
# Set working directory
WORKDIR /app
#RUN yarn global add turbo
RUN npm install turbo --global
COPY . .
 
# Generate a partial monorepo with a pruned lockfile for a target workspace.
RUN turbo prune web --docker # Assuming "web" is the name entered in the project's package.json: { name: "web" }
 
# Add lockfile and package.json's of isolated subworkspace
FROM base AS installer
RUN apk add --no-cache libc6-compat
RUN apk update
WORKDIR /app
 
# First install the dependencies (as they change less often)
COPY .gitignore .gitignore
COPY --from=builder /app/out/json/ .
#COPY --from=builder /app/out/yarn.lock ./yarn.lock
COPY --from=builder /app/out/package-lock.json ./package-lock.json
#RUN yarn install
RUN npm install
 
# Build the project
COPY --from=builder /app/out/full/ .
#RUN yarn turbo run build --filter=web...
#RUN turbo build --filter=web
#RUN turbo run build --filter=web
RUN npx turbo run build --filter=web
 
FROM base AS runner
WORKDIR /app
 
# Don't run production as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs
 
COPY --from=installer /app/apps/web/next.config.js .
COPY --from=installer /app/apps/web/package.json .
 
# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=installer --chown=nextjs:nodejs /app/apps/web/.next/standalone ./
COPY --from=installer --chown=nextjs:nodejs /app/apps/web/.next/static ./apps/web/.next/static
COPY --from=installer --chown=nextjs:nodejs /app/apps/web/public ./apps/web/public
 
CMD node apps/web/server.js
