# Sécurité

## Objectifs
- Chiffrement : TLS partout (intra-cluster + clients)
- AuthN : mTLS et/ou SCRAM-SHA-512
- AuthZ : ACLs (simple) avec deny-by-default
- Isolation réseau : NetworkPolicy (ingress/egress)
- Secrets : Kubernetes Secrets + rotation

## Approche recommandée (Strimzi)
- Listener TLS interne (9093), auth `tls`
- `KafkaUser` en `tls` => Strimzi génère un Secret avec cert/key client
- ACLs : topics/groupes explicitement autorisés

## Patterns
- Namespace `kafka` = socle
- Namespaces équipes = clients
- Autoriser réseau uniquement depuis namespaces autorisés vers service Kafka (TLS)

Voir : `platform/security/networkpolicies/*`
