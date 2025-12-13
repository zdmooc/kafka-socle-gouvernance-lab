# Roadmap projet – Socle Kafka

## Objectif final
Livrer un **cluster Kafka opérationnel**, gouverné, monitoré et exploitable en RUN (L2/L3), avec :
- Guide d’usage (topics, schémas, droits, conventions)
- Procédures d’exploitation (MEX + runbooks)
- Transfert de compétences (formation + coaching)
- Reporting hebdomadaire (indicateurs de service)

---

## Phase 0 — Cadrage (Semaine 1)
### Actions
- Collecter besoins : volumes, latence, SLA/SLO, périmètre (Streams/Connect), contraintes sécurité
- Cartographier les flux existants et cibles
- Définir les environnements : dev / recette / préprod / prod + stratégie DR
- Choisir standards : naming, partitions, rétention, schémas, compatibilité, ACL

### Livrables
- `docs/01-ARCHITECTURE.md` (C4 + vues HA/DR)
- `docs/02-GOVERNANCE.md` (standards, règles, modèle de topic)
- `docs/03-SECURITE.md` (TLS/SASL, RBAC, NetworkPolicy, secrets)
- `docs/09-REPORTING.md` (KPIs, SLI/SLO, format hebdo)

---

## Phase 1 — Déploiement socle (Semaines 2–3)
### Actions
- Installer Strimzi (operator)
- Déployer un cluster Kafka :
  - Profil local (validation pipeline)
  - Profil HA (brokers + controllers, anti-affinité, storage)
- Exposer listeners internes et (si besoin) externes
- Mettre en place topics et users “de base”
- Smoke tests

### Livrables
- Manifests : `platform/kafka/clusters/*`, `platform/kafka/topics`, `platform/kafka/users`, `platform/kafka/smoke`
- Runbook d’installation : `docs/05-RUNBOOKS.md` (install/upgrade/rollback)

---

## Phase 2 — Observabilité (Semaine 4)
### Actions
- Exposer métriques (JMX exporter via metricsConfig)
- Déployer Prometheus/Grafana (ou s’intégrer à la stack existante)
- Alerting (PrometheusRule) + SLO/SLI

### Livrables
- `docs/04-OBSERVABILITE.md`
- `platform/observability/*`

---

## Phase 3 — Gouvernance avancée (Semaines 5–6)
### Actions
- Topic lifecycle : création, changements, dépréciation, suppression
- Schémas : registry (option), compatibilité, versionning
- Modèle d’ACL : patternType, groupes, séparation des duties
- Templates SNOW : cadrage, impact, devis/abaques/UO, planning, go/no-go

### Livrables
- `docs/02-GOVERNANCE.md`
- `docs/10-SNOW-WORKFLOW.md`
- Templates (SFD/STD/MEX) : `docs/templates/*`

---

## Phase 4 — RUN L2/L3 (continu)
### Actions
- Procédures : incident, problem, change, capacity, patching
- Maintenances préventives : upgrade Strimzi/Kafka, tuning, cleanups
- DR : test de bascule, réplication (MirrorMaker2), RPO/RTO

### Livrables
- `docs/05-RUNBOOKS.md`, `docs/07-DR.md`
- `scripts/report-weekly.sh` + `docs/09-REPORTING.md`

---

## Phase 5 — Transfert de compétences (continu)
### Actions
- Sessions formation (fondamentaux Kafka, Strimzi, sécurité, exploitation)
- Coaching sur tickets réels, revue de PR Git, revue d’archi
- Capitalisation : MEX, KB articles, checklists

### Livrables
- `docs/08-FORMATION.md`
- `docs/KB/` (articles à produire au fil de l’eau)
