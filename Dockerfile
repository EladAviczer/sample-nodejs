# Stage 1: Install production dependencies
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev


# Stage 2: Minimal runtime without npm
FROM alpine:3.22

RUN apk add --no-cache nodejs

ENV NODE_ENV=production
ENV PORT=8080

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY app.js ./

USER 1000:1000

EXPOSE 8080

CMD ["node", "app.js"]