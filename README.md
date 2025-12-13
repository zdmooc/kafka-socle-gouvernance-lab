# Socle Kafka – RUN/L2-L3, Gouvernance, Observabilité, DevOps (projet complet)

Ce dépôt est un **projet réalisable** (portfolio + CV) : il vous guide pour concevoir, déployer, sécuriser, exploiter et industrialiser un **socle Kafka** sur Kubernetes/OpenShift avec :
- **RUN L2/L3** (correctif / préventif, astreinte, diagnostic, RCA)
- **Évolutions** (nouveaux flux, topics, connecteurs, Streams)
- **Gouvernance** (standards, conventions, schémas, droits, MEX)
- **Observabilité** (Prometheus/Grafana, alertes, SLO/SLI)
- **DevOps** (GitOps Argo CD optionnel, CI/CD exemples, IaC manifests)
- **Transfert de compétences** (formation + coaching + base de connaissance)
- **Reporting hebdo** (indicateurs de service + capacité/usage)

> Implémentation de référence : **Strimzi** (Kafka on Kubernetes/OpenShift).  
> OpenShift : Strimzi est aussi distribué via Red Hat Streams for Apache Kafka (AMQ Streams).

---

## Démarrage rapide (Kubernetes)
### Prérequis
- `kubectl`, `helm`, accès à un cluster (Kind / k3d / AKS / EKS / GKE…)
- (Optionnel) `argo`/Argo CD installé si vous utilisez le dossier GitOps

### 1) Installation Strimzi (operator)
```bash
kubectl create ns kafka
helm repo add strimzi https://strimzi.io/charts/
helm repo update

# L'operator observe kafka + kafka-apps (valeurs dans platform/strimzi/helm/values.yaml)
helm upgrade --install strimzi strimzi/strimzi-kafka-operator   -n kafka -f platform/strimzi/helm/values.yaml
```

### 2) Déploiement du cluster Kafka
**Profil local (1 nœud, léger)**
```bash
kubectl apply -n kafka -f platform/kafka/clusters/local/
```

**Profil HA (3 brokers + 3 controllers)**
```bash
kubectl apply -n kafka -f platform/kafka/clusters/ha/
```

### 3) Gouvernance minimale (topics + users)
```bash
kubectl apply -n kafka -f platform/kafka/topics/
kubectl apply -n kafka -f platform/kafka/users/
```

### 4) Smoke tests (via Job Kafka CLI)
```bash
kubectl apply -n kafka -f platform/kafka/smoke/
kubectl logs -n kafka job/kafka-smoke -f
```

---

## Démarrage rapide (OpenShift)
- Utilisez `oc` à la place de `kubectl`.
- Vous pouvez installer Strimzi via Helm (ci-dessus) ou via OperatorHub / AMQ Streams selon le contexte.

---

## Structure
- `docs/` : architecture, gouvernance, sécurité, runbooks, reporting, formation
- `platform/` : manifests Kubernetes/OpenShift (Kafka, Topics, Users, Connect, monitoring)
- `apps/` : exemples (producer/consumer + Kafka Streams minimal)
- `scripts/` : bootstrap, déploiement, smoke tests, reporting hebdo

---

## Parcours projet (à dérouler comme une mission réelle)
Consultez : `docs/ROADMAP.md` (phases, jalons, critères d’acceptation, livrables).

---

## Références (documentation)
- Strimzi (déploiement, configuration, CRDs) : https://strimzi.io/docs/operators/latest/  (voir aussi : examples/latest)
- Exemple KafkaUser (ACL) : https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/main/examples/user/kafka-user.yaml
- Exemples Strimzi (clusters/topics/connect) : https://strimzi.io/examples/latest/
