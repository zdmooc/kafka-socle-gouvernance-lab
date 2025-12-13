# Observabilité (Prometheus / Grafana)

## Métriques
- Brokers/controllers : CPU, mémoire, I/O, latence produce/fetch, ISR, under-replicated partitions
- Topics : bytes-in/out, messages-in, retention, compaction
- Consumer lag (via exporter / outils)
- Connect : task status, retries, DLQ
- SLO/SLI : disponibilité, latence, backlog

## Stack cible
- Prometheus Operator (ou kube-prometheus-stack)
- Grafana (dashboards Kafka/Strimzi + dashboards internes)
- Alertmanager (routage alertes)

## Manifests
- ServiceMonitors / PrometheusRules : `platform/observability/*`

> Note : Strimzi fournit des exemples de dashboards et de configs de métriques dans son dépôt; ce projet fournit une base minimaliste à personnaliser.
