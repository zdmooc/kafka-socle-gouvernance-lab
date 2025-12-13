# Architecture cible (Socle Kafka)

## Vue d’ensemble (C4 – Container)
```mermaid
flowchart LR
  subgraph K8S[Kubernetes / OpenShift]
    subgraph NS_KAFKA[Namespace kafka]
      OP[Strimzi Operator]
      K[Kafka Cluster (KRaft)]
      EO[Entity Operator<br/>Topic & User Operators]
      KC[Kafka Connect (option)]
      MM2[MirrorMaker2 (option DR)]
    end

    subgraph NS_APPS[Namespaces équipes (kafka-apps, team-a, team-b...)]
      P[Producers]
      C[Consumers]
      S[Kafka Streams Apps]
      CONN[KafkaConnector CRs]
    end

    subgraph OBS[Observability]
      PR[Prometheus]
      GR[Grafana]
      AM[Alertmanager]
    end
  end

  P -->|events| K
  K --> C
  S <--> K
  KC <--> K
  PR --> K
  PR --> KC
  GR --> PR
  MM2 -->|replication| K2[(DR Cluster)]
```

## Principes
- **KRaft** (sans ZooKeeper) pour la modernité et la simplification (selon version supportée).
- **Séparation** : `kafka` pour le socle, `kafka-apps`/équipes pour les workloads.
- **Infra as Code** : manifests versionnés, revus, déployés via GitOps (option).
- **Security by default** : TLS interne, ACL deny-by-default, NetworkPolicy.
- **Observabilité** : métriques + alertes + reporting (SLO/SLI + capacity).

## HA / DR (cibles)
- **HA** : 3 brokers + 3 controllers, anti-affinité, storage persistant.
- **DR** :
  - MirrorMaker2 (asynchrone) pour topics critiques
  - Runbook bascule + tests périodiques (RPO/RTO)
