FROM node:12-alpine
# Adding build tools to make yarn install work on Apple Silicon / arm64 machines
RUN apk add --no-cache python2 g++ make
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "src/index.js"]
