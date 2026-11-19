# Stage 1: Install production dependencies
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev


# Stage 2: Minimal production runtime
FROM gcr.io/distroless/nodejs22-debian13:nonroot

ENV NODE_ENV=production

WORKDIR /app

COPY --from=builder --chown=1000:1000 /app/node_modules ./node_modules
COPY --chown=1000:1000 package.json app.js ./

USER 1000:1000

EXPOSE 8080

CMD ["app.js"]
