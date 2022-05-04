FROM node:lts-alpine3.14

WORKDIR /app
COPY package.json /app
RUN npm install

COPY . .

EXPOSE 80
CMD [ "node", "index.js" ]