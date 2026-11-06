FROM node:22.23.4-alpine3.24 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

FROM node:22.23.4-alpine3.24
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app.js ./
EXPOSE 8080
USER node
CMD ["node", "app.js"]
