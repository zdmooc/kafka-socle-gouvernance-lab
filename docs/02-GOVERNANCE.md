# Gouvernance & bonnes pratiques

## Conventions de nommage (exemples)
- Topics : `{domaine}.{event}.{version}`  
  Exemple : `billing.invoice.created.v1`
- Consumer groups : `{team}.{app}.{usecase}`  
  Exemple : `team-a.invoice-service.enrichment`
- Connectors : `{team}.{system}.{flow}`  
  Exemple : `team-a.sap.orders-source`

## Standards topics
- Partitions : dimensionnées sur **débit** et **parallélisme**, avec croissance prévue
- Réplication : 3 en HA (selon cluster)
- Rétention : par défaut 7–14j, ajustée par criticité (ou compaction)
- `min.insync.replicas` + `acks=all` pour flux critiques
- `auto.create.topics.enable=false` (création contrôlée)

## Cycle de vie
1. Demande (SNOW) + cadrage + impact
2. Validation gouvernance (review)
3. Création topic + user + ACL
4. Onboarding (runbook, alerting, dashboards)
5. Dépréciation / migration / suppression

## Modèle de droits (ACL)
- Principes : **least privilege**, deny-by-default, séparation par équipe
- ACLs Strimzi : `KafkaUser.spec.authorization.type=simple` + règles `acls`
- Usage des `prefix` pour groupes/collections si besoin, sinon `literal`

## Schémas (option)
- Stratégie : JSON Schema / Avro / Protobuf
- Compatibilité : backward (par défaut), versionning explicite
- Registry : Apicurio / Confluent (selon choix orga) – prévoir runbook + backup

## Templates
- SFD : `docs/templates/SFD.md`
- STD : `docs/templates/STD.md`
- MEX : `docs/templates/MEX.md`
