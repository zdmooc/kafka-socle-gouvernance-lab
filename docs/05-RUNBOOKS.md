# Runbooks (RUN L2/L3)

## 1. Exploitation quotidienne
- Vérifier état cluster (pods, CRs Strimzi)
- Vérifier ISR / partitions sous-répliquées
- Vérifier lag groupes critiques
- Vérifier alertes Prometheus + tendances

## 2. Incidents (L2)
- Symptômes : timeouts produce/consume, erreurs auth, brokers restart loop
- Quick checks : `kubectl get kafkas -n kafka`, `kubectl describe`, logs operator/brokers
- Contournements : scale consumer, pause connect tasks, increase partitions (avec gouvernance)

## 3. Problèmes (L3) / RCA
- Collecte : timeline, dashboards, logs, configs, changements récents
- RCA : cause racine + actions correctives + prévention (MEX)
- Capitalisation : KB + runbook + alertes

## 4. Maintenance préventive
- Upgrade Strimzi (operator) + upgrade Kafka (rolling)
- Vérification compatibilité clients
- Tests de non-régression (smoke + perf de base)

## 5. Changes / Releases
- Process : RFC, revue, approbation, fenêtre, plan de rollback
- Evidence : captures, exports, checklists

Scripts : `scripts/*`
