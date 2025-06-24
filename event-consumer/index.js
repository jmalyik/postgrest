const express = require('express');
const { Kafka } = require('kafkajs');

const app = express();
const PORT = 4000;

const kafka = new Kafka({
  clientId: 'event-consumer',
  brokers: [process.env.KAFKA_BROKER && process.env.KAFKA_BROKER.trim() !== '' ? process.env.KAFKA_BROKER : 'redpanda:9092']
});

const topic = process.env.TOPIC || 'dbserver1.public.items';
const consumer = kafka.consumer({ groupId: 'consumer-group' });

async function start() {
  await consumer.connect();
  await consumer.subscribe({ topic, fromBeginning: true });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log(`[Kafka][${topic}]`, message.value.toString());
    }
  });
}

start().catch(console.error);

app.listen(PORT, () => {
  console.log(`Event consumer listening on port ${PORT}`);
});
