# stage 1: builder
FROM node:22.23.4-alpine3.24 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# stage 2: The final image
FROM node:22.23.4-alpine3.24
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app.js ./
EXPOSE 8080
USER node
CMD ["node", "app.js"]
