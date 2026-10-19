# Kafka / OpenShift — Audit consolidé et plan de modernisation

**Date du contrôle :** 19 octobre 2026  
**Statut :** `DOCUMENTARY_AUDIT / VERIFIED_FILE_FINDINGS / NO_RUNTIME_VALIDATION`  
**Responsable :** socle Kafka, gouvernance, RUN et plateforme OpenShift.  
**Objet :** conserver en **un seul document** les constats réutilisables des quatre documents d'audit du laboratoire privé `mayabank-kafka-ddd-openshift`, sans copier ce laboratoire ni créer un deuxième produit Kafka.  
**Provenance :** `mayabank-kafka-ddd-openshift` branche `main` à `6357b06809fcbfd99962fae8116db50c1280c46a`. Les fichiers source étaient `docs/audit/KAFKA_REPOSITORY_AUDIT.md`, `KAFKA_DUPLICATION_MATRIX.md`, `KAFKA_TECH_DEBT.md` et `KAFKA_MODERNIZATION_PLAN.md`.

> Les observations dites **VÉRIFIÉ DANS GIT** ci-dessous résultent de la lecture des fichiers concernés le 19/10/2026. Les jugements de conception sont des **RECOMMANDATIONS**, pas des corrections exécutées. Aucune CI, commande `oc`, installation Kafka, mesure de performance, test de panne ou mise en production n'a été réalisé lors de cette consolidation.

## 1. Décision de rationalisation et responsabilités

| Dépôt | Responsabilité pérenne | État retenu |
|---|---|---|
| **[kafka-socle-gouvernance-lab](../README.md)** | Propriétaire des architectures Strimzi/KRaft, manifests, gouvernance, sécurité, RUN et HA de référence | **KEEP / OWNER** ; dette documentée, remédiation non exécutée |
| [kafka-data-engineer-kafkaops-topic-service-crc](https://github.com/zdmooc/kafka-data-engineer-kafkaops-topic-service-crc) | Opérations Kafka, Topic-as-a-Service, CLI, Ansible, parcours CRC et runbooks | **KEEP / SPECIALIST** ; manifeste CRC hérité à moderniser |
| [kafka-expert](https://github.com/zdmooc/kafka-expert) | HLD/DDL et exemples Data Engineering historiques ; **dépôt archivé**, branche `master` | **ARCHIVE / HISTORICAL_REFERENCE** ; ne pas reprendre son sizing ni ses exemples de secrets comme standards |
| `kafka-complete-masterclass` | Support pédagogique historique mentionné par l'audit source | **NOT_ACCESSIBLE 19/10/2026** ; ne pas présumer de son contenu actuel ni de sa suppression définitive |
| [mayabank-instant-payments-resilience-platform](https://github.com/zdmooc/mayabank-instant-payments-resilience-platform) | Propriétaire **métier** de la transaction paiement, Outbox, Inbox/idempotence, événements, réconciliation et preuves CRC | **KEEP / PAYMENT_OWNER** |
| `mayabank-kafka-ddd-openshift` | Ancien dépôt d'intention Kafka/DDD ; 5 fichiers Markdown, aucun service ou manifeste déployable | **RETIREMENT_CANDIDATE** ; ce document conserve les observations techniques utiles ; suppression **non exécutée** |

**Ne pas fusionner les plateformes technique et produit.** La plateforme Kafka publie les capacités et les standards. Le domaine paiement fixe son contrat d'événements, son modèle de cohérence et les preuves d'intégration. Le domaine métier n'a pas à réimplémenter le broker.

## 2. Constats actuels vérifiés directement

| ID | Priorité | Constat constaté dans Git | Risque | Traitement recommandé |
|---|---|---|---|---|
| KF-01 | **P0** | Dans [cluster local](../platform/kafka/clusters/local/20-kafka-single-node.yaml) et [HA](../platform/kafka/clusters/ha/20-kafka-ha.yaml), la config Kafka `4.1.1` inclut `inter.broker.protocol.version: "4.1"`. | Propriété retirée à partir de Kafka 4.0 ; manifest risquant de ne pas être applicable. | Retirer cette propriété après validation des valeurs Kafka/Operator/metadataVersion ; rendre en CI et vérifier sur cluster. |
| KF-02 | **P0** | Le [Kafka CR de KafkaOps CRC](https://github.com/zdmooc/kafka-data-engineer-kafkaops-topic-service-crc/blob/main/openshift/manifests/kafka/kafka-cluster.yaml) déclare `kafka.strimzi.io/v1beta2`, Kafka `3.7.0`, `spec.zookeeper`, `spec.kafka.replicas`, stockage éphémère et listener sans TLS. | Modèle obsolète si réutilisé avec l'Operator moderne ; pas de socle bancaire de production. | Reconstruire **un nouveau profil KRaft** avec `KafkaNodePool` et version CRD supportée, ne pas simplement éditer le manifeste ancien en production. |
| KF-03 | **P1** | [Script OperatorHub KafkaOps](https://github.com/zdmooc/kafka-data-engineer-kafkaops-topic-service-crc/blob/main/openshift/crc/10-install-strimzi-operator.sh) : valeurs présumées `CHANNEL=stable` / `SOURCE=redhat-operators`, recherche le premier CSV `.items[0]` et termine après la boucle sans erreur explicite de timeout. | Faux succès d'installation / mauvaise version sélectionnée. | Découverte PackageManifest/Subscription, filtrage du CSV voulu, deadline avec `exit != 0`, contrôle réel de readiness. |
| KF-04 | **P1** | Le [profil HA du socle](../platform/kafka/clusters/ha/20-kafka-ha.yaml) possède un listener `plain` (`tls: false`) en plus de TLS. | Risque d'exposition non chiffrée si copié en environnement sensible. | Supprimer/désactiver les accès non chiffrés en profil banque, vérifier les identités, TLS et ACL. |
| KF-05 | **P1** | [Profil local](../platform/kafka/clusters/local/20-kafka-single-node.yaml) : un nœud controller+broker et stockage éphémère. | Perte de disponibilité/données en cas de panne ou redéploiement. | Marquer **LAB ONLY**, ne jamais inférer de HA ou de durabilité production. |
| KF-06 | **P1** | [Profil HA](../platform/kafka/clusters/ha/20-kafka-ha.yaml) : trois controllers et trois brokers avec PVC, mais sans requests/limits explicites pour ces NodePools. | Absence de sizing et garantie de placement/ressources vérifiables. | Calculer sizing, contraintes de topology/anti-affinity, capacité stockage et tests de failover. |
| KF-07 | **P2** | [DDL archivé kafka-expert](https://github.com/zdmooc/kafka-expert/blob/master/architecture/DDL_Kafka.md) comporte un sizing générique et des exemples de mots de passe littéraux. | Réutilisation non contextualisée / hygiène sécurité insuffisante. | Garder comme exemple **historique**, pas comme DDL production ; exigences et secrets externalisés. |
| KF-08 | **P2** | [Consumer archivé kafka-expert](https://github.com/zdmooc/kafka-expert/blob/master/python/consumers/basic_consumer.py) conserve une logique métier `TODO`. | Démonstrateur pédagogique présenté à tort comme service de traitement. | Ne pas le promouvoir comme application de paiements. |

### Nuances

- `KF-01` est cohérent avec la [KIP-1001 Apache Kafka](https://cwiki.apache.org/confluence/spaces/KAFKA/pages/278465479/KIP-1001+Some+New+Metrics+and+Config+Key+Deprecations), qui prévoit le retrait de `inter.broker.protocol.version` en Kafka 4.0.
- Les exemples de [Red Hat Streams for Apache Kafka 3.2](https://docs.redhat.com/en/documentation/red_hat_streams_for_apache_kafka/3.2/html/deploying_and_managing_streams_for_apache_kafka_on_openshift/overview-str) utilisent `Kafka` et `KafkaNodePool` en `kafka.strimzi.io/v1`. Il faut cependant confirmer la **matrice de compatibilité exacte de l'Operator installé**, ses CRDs et la version Kafka disponible lors du déploiement.
- L'observation de manifests incorrects ou anciens **ne signifie pas qu'un cluster existant soit en panne** : aucun état runtime n'a été interrogé.

## 3. Matrice d'ownership : réutiliser, adapter ou abandonner

| Capacité | Dépôt propriétaire | Mode de traitement |
|---|---|---|
| KRaft, `KafkaNodePool`, versions, politiques de listeners | **Socle Kafka** | Corriger/valider dans le dépôt de plateforme |
| Brokers, partitions, ISR, réplication, stockage, HA/PRA, SLO | **Socle Kafka** | Exigences et preuves d'exploitation |
| KafkaOps CLI, Topic-as-a-Service et processus de catalogue | **KafkaOps CRC** | Adapter son profil Kafka ancien ; conserver les outils spécialisés |
| HLD Kafka général, architecture Data Engineering historique | **kafka-expert (archive)** | Référence conceptuelle, pas source déployable |
| DDD, bounded contexts, événements de paiement, états financiers | **Instant Payments** | Garder dans le produit ; Kafka n'est qu'un choix d'intégration |
| Outbox, Inbox, idempotence, reprise après indisponibilité broker | **Instant Payments** | Réutiliser ses tests et preuves existants ; ne pas recréer un laboratoire concurrent |
| Kafka vs REST vs MQ | **Décision au niveau de chaque flux métier**, avec expertise plateforme | ADR fondée sur transactionnalité, latence, autonomie, exploitation et risques |
| Installation opérateur OpenShift / validation CRD | **Socle Kafka et KafkaOps** | Découverte explicite sur le cluster visé |
| Formation Kafka de base | Référentiels pédagogiques disponibles et sources officielles | Pas de cinquième cours redondant |

Les documents `KAFKA_DUPLICATION_MATRIX.md` et `KAFKA_MODERNIZATION_PLAN.md` du dépôt source exprimaient des **intentions futures** (« DDD à construire », « Outbox à construire »). En octobre 2026, ces thèmes existent déjà dans le [POC Instant Payments](https://github.com/zdmooc/mayabank-instant-payments-resilience-platform) ; **ne pas créer un second propriétaire de ces fonctionnalités**. Cette réallocation est une décision de consolidation, pas une migration de code.

## 4. Backlog de remédiation mesurable (non exécuté)

### M1 — Corriger le socle Kafka actuel (P0)

1. Découvrir l'Operator/versions réellement retenus et récupérer les schémas de CRD correspondant à la cible.
2. Retirer `inter.broker.protocol.version` des profils Kafka 4.x et revalider `metadataVersion`/upgrade path.
3. Vérifier `kubectl/oc apply --dry-run=server` et/ou rendu/policy dans un environnement adapté ; un `--dry-run=client` n'établit pas la compatibilité CRD.
4. Exécuter smoke tests producer/consumer + Topic/User + sécurité et consigner commits, versions et résultats.
5. Séparer strictement `LAB ONLY` et `PRODUCTION REFERENCE`.

**Sortie attendue :** manifests rendus/acceptés par la version supportée, broker `Ready`, publication/consommation de messages, preuves de TLS/auth selon profil ; pas de claim HA depuis un seul nœud.

### M2 — Moderniser l'installation KafkaOps CRC (P0/P1)

1. Identifier les catalogues/packages/channels exacts disponibles dans OperatorHub.
2. Sélectionner explicitement la Subscription et suivre le CSV associé jusqu'à `Succeeded` ou à un timeout **bloquant**.
3. Remplacer le modèle ZooKeeper/`v1beta2` par un modèle KRaft et `KafkaNodePool` supporté.
4. Vérifier `oc get kafka,kafkanodepool,kafkatopic,kafkauser` et les events/conditions associés.
5. Tester reprise, bootstrap et nettoyage dans un environnement de labo isolé.

**Sortie attendue :** installation et vérification reproductibles ; les scripts anciens restent historiques tant qu'ils ne sont pas corrigés.

### M3 — Sécurité/HA/sizing (P1)

- Pour une **référence** HA, dimensionner controllers/brokers, storage et réplication selon objectifs et volumétrie ; la topologie 3+3 n'est pas un dimensionnement universel.
- Contrôler TLS, mTLS/SASL, ACL, certificats, namespaces et politiques réseau. Pas de listener non chiffré en profil cible bancaire sans décision explicite et acceptable.
- Évaluer placement inter-workers/inter-zones et dom. de panne, `topologySpread`/anti-affinity, budgets d'indisponibilité, backup/DR et observabilité.
- Définir les tests de panne **avant** d'émettre des revendications HA/RTO/RPO.

### M4 — Sizing piloté par les besoins (P2)

Mesures à collecter : transactions/s nominal/pic, événements/transaction, taille comprimée des événements, durées de rétention/compaction, RF, `min.insync.replicas`, multiplicité des groupes consumer, taux de replay, bande passante, capacité disque, overhead et croissance.

Une approximation de trafic **brut** peut s'écrire :

```text
Ingress_bytes/s = payments_per_second
                  * events_per_payment
                  * average_event_bytes

Storage_raw ≈ Ingress_bytes/s * retention_seconds * replication_factor
```

La capacité réellement nécessaire exige en plus marge, index/segments, compression effective, partitions, rebalance, états transitoires et conditions de reprise. **Aucun nombre de brokers, CPU, RAM ou To n'est garanti par cette formule seule.**

## 5. Contrôles à conserver pour le cas Instant Payments

| Scénario | Invariant et preuve attendue | Owner |
|---|---|---|
| Paiement validé puis Kafka indisponible | Transaction financière durable + Outbox conservée ; pas de retry client créant un deuxième paiement | Produit |
| Redémarrage du publisher | Publication durable, pas de perte et gestion des doublons | Produit + broker |
| Deux émissions du même événement | Inbox/consumer idempotent : une seule conséquence métier | Produit |
| Consumer ralenti puis rattrapé | Lag observable, backpressure et absence d'effet métier en double | Produit + plateforme |
| Déploiement nouveau schéma | Compatibilité contrats producteurs/consommateurs et rollback contrôlé | Produit |
| Panne broker / zone | Durabilité et RTO/RPO mesurés sur architecture multi-worker adaptée | Plateforme + produit |

Le [référentiel Claim → Evidence d'Instant Payments](https://github.com/zdmooc/mayabank-instant-payments-resilience-platform/blob/main/docs/evidence/CLAIM-EVIDENCE-MATRIX.md) contient déjà des preuves de reprise Outbox/Inbox sur **OpenShift Local mono-nœud**. Elles n'établissent **ni** la HA multi-nœuds du socle Kafka générique **ni** les garanties production.

## 6. Traçabilité des observations et limites

**Échantillons Git directement vérifiés le 19/10/2026 :**

- [Socle Kafka — profil local](../platform/kafka/clusters/local/20-kafka-single-node.yaml) et [profil HA](../platform/kafka/clusters/ha/20-kafka-ha.yaml), branche `main` à `6dd9e24b5c9707772cd103feb053a201a4eee698`.
- [KafkaOps — manifeste hérité](https://github.com/zdmooc/kafka-data-engineer-kafkaops-topic-service-crc/blob/main/openshift/manifests/kafka/kafka-cluster.yaml) et [installation OperatorHub](https://github.com/zdmooc/kafka-data-engineer-kafkaops-topic-service-crc/blob/main/openshift/crc/10-install-strimzi-operator.sh), `main` à `df9b4c7231015740711e743e1655dea222d78505`.
- [kafka-expert](https://github.com/zdmooc/kafka-expert) est archivé ; [DDL](https://github.com/zdmooc/kafka-expert/blob/master/architecture/DDL_Kafka.md) et [consumer](https://github.com/zdmooc/kafka-expert/blob/master/python/consumers/basic_consumer.py) vérifiés sur `master` à `2e41ea86a53e2bc544b4f1b7644717307dd07da1`.
- `kafka-complete-masterclass` n'était pas accessible sur GitHub avec l'identifiant ancien lors de cet audit : **pas de constat présent sur ses fichiers**.
- Audit préparatoire privé `mayabank-kafka-ddd-openshift` : cinq fichiers Markdown, aucun code de service ni YAML déployable. Aucun de ces cinq fichiers n'est copié verbatim dans le présent dépôt.

**Ce qui n'a pas été vérifié :** état réel des clusters, version de l'Operator actuellement installée, compilation/smoke de ces manifestes, volume d'activité, performances, tests HA, couverture complète des autres dépôts GitHub. Les constats s'appliquent **aux fichiers inspectés**, pas à toute une production bancaire.

## 7. Licence, sources et décision de conservation

```yaml
LICENSE_GATE: PASS # pour cette synthèse technique originale et ce changement seulement
repository: zdmooc/kafka-socle-gouvernance-lab
branch: main
visibility: public
existing_license: Apache-2.0 (LICENSE inchangé)
change: synthèse nouvelle de constats techniques publics et de l'audit préparatoire privé du même portefeuille
original_source_reference: mayabank-kafka-ddd-openshift@6357b06809fcbfd99962fae8116db50c1280c46a
copied_private_documents: none
third_party_material: liens et concepts techniques, aucune reproduction de code/texte éditeur
binary_dependencies_datasets_models: aucun ajout
changes_to_repository_visibility: none
runtime_changes: none
limits: droits et provenance à recontrôler avant toute republication ou réutilisation de contenus tiers
```

La publication de ce résumé technique ne republie ni documentation protégée des éditeurs, ni artefacts de dépôt privé, ni données client. L'Apache-2.0 existante du dépôt destinataire est préservée. La licence globale du reste du portefeuille n'est pas changée.

**Décision :** un référentiel Kafka plateforme, une plateforme paiement propriétaire de ses événements, un dépôt KafkaOps propriétaire de ses outils. `mayabank-kafka-ddd-openshift` peut être proposé au retrait **après contrôle des liens et confirmation explicite du propriétaire** ; cette consolidation n'autorise pas sa suppression automatique.
