import os, json, time, datetime
from kafka import KafkaProducer

BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "socle-kafka-kafka-bootstrap.kafka.svc:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "demo.events.v1")

producer = KafkaProducer(
    bootstrap_servers=BOOTSTRAP.split(","),
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
    key_serializer=lambda v: v.encode("utf-8"),
    acks="all",
    retries=3,
)

i = 0
while True:
    i += 1
    msg = {"id": i, "ts": datetime.datetime.utcnow().isoformat() + "Z", "type": "demo"}
    producer.send(TOPIC, key="demo", value=msg)
    producer.flush()
    print(f"sent {msg}")
    time.sleep(float(os.getenv("SLEEP_SEC", "1")))
