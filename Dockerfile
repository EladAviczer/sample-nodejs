FROM node:22.23.4-alpine3.24@sha256:0e1754758c2df4cfa3e68d59e2e1b7374bb7fd9ea6328eaaacf15cc934af8202 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

FROM node:22.23.4-alpine3.24@sha256:0e1754758c2df4cfa3e68d59e2e1b7374bb7fd9ea6328eaaacf15cc934af8202
# npm is only needed to install packages in the builder stage; removing it drops its vulnerable dependencies
RUN rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app.js ./
EXPOSE 8080
USER node
CMD ["node", "app.js"]
