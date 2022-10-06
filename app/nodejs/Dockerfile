FROM node:lts-alpine3.14

WORKDIR /app
COPY package.json /app
RUN npm install

COPY . .

EXPOSE 8080
CMD [ "node", "index.js" ]