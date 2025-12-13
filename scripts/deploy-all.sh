#!/usr/bin/env bash
set -euo pipefail

echo "[1/7] Create namespaces"
kubectl apply -f platform/kafka/clusters/local/00-namespace.yaml
kubectl apply -f platform/namespaces/kafka-apps.yaml

echo "[2/7] Install Strimzi operator (helm)"
helm repo add strimzi https://strimzi.io/charts/ >/dev/null 2>&1 || true
helm repo update >/dev/null
helm upgrade --install strimzi strimzi/strimzi-kafka-operator -n kafka -f platform/strimzi/helm/values.yaml

echo "[3/7] Deploy Kafka (local profile)"
kubectl apply -n kafka -f platform/kafka/clusters/local/

echo "[4/7] Wait for Kafka CR Ready (best-effort)"
kubectl wait --for=condition=Ready kafka/socle-kafka -n kafka --timeout=900s || true

echo "[5/7] Apply governance (topics/users)"
kubectl apply -n kafka -f platform/kafka/topics/
kubectl apply -n kafka -f platform/kafka/users/

echo "[6/7] Apply security (NetworkPolicy - optional)"
kubectl apply -f platform/security/networkpolicies/ || true

echo "[7/7] Smoke test"
kubectl apply -n kafka -f platform/kafka/smoke/
kubectl logs -n kafka job/kafka-smoke -f
