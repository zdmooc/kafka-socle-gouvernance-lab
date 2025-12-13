import os, json
from kafka import KafkaConsumer

BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "socle-kafka-kafka-bootstrap.kafka.svc:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "demo.events.v1")
GROUP = os.getenv("KAFKA_GROUP", "demo-app")

consumer = KafkaConsumer(
    TOPIC,
    bootstrap_servers=BOOTSTRAP.split(","),
    group_id=GROUP,
    auto_offset_reset="earliest",
    enable_auto_commit=True,
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    key_deserializer=lambda v: v.decode("utf-8") if v else None,
)

for msg in consumer:
    print({"topic": msg.topic, "partition": msg.partition, "offset": msg.offset, "key": msg.key, "value": msg.value})
