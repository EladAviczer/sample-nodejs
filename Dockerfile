FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY --chown=node:node app.js ./

USER node

EXPOSE 8080

CMD ["node", "app.js"]
