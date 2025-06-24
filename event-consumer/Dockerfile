FROM node:20

ENV KAFKA_BROKER=redpanda:9092

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install && echo $KAFKA_BROKER
COPY . .
CMD ["node", "index.js"]