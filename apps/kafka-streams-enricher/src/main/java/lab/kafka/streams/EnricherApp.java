package lab.kafka.streams;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;

import java.time.Duration;
import java.util.Properties;

public class EnricherApp {
  public static void main(String[] args) {
    String bootstrap = env("KAFKA_BOOTSTRAP", "socle-kafka-kafka-bootstrap.kafka.svc:9092");
    String inTopic = env("IN_TOPIC", "demo.events.v1");
    String outTopic = env("OUT_TOPIC", "demo.events.enriched.v1");
    String appId = env("APP_ID", "streams-enricher");

    Properties props = new Properties();
    props.put(StreamsConfig.APPLICATION_ID_CONFIG, appId);
    props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
    props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
    props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
    props.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, "2000");

    StreamsBuilder builder = new StreamsBuilder();
    KStream<String, String> input = builder.stream(inTopic, Consumed.with(Serdes.String(), Serdes.String()));

    KStream<String, String> enriched = input.mapValues(v -> v + " | enriched=true");
    enriched.to(outTopic, Produced.with(Serdes.String(), Serdes.String()));

    Topology topology = builder.build();
    KafkaStreams streams = new KafkaStreams(topology, props);

    Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    streams.start();
  }

  private static String env(String k, String d) {
    String v = System.getenv(k);
    return (v == null || v.isBlank()) ? d : v;
  }
}
