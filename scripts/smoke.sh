#!/usr/bin/env bash
set -euo pipefail
kubectl apply -n kafka -f platform/kafka/smoke/
kubectl logs -n kafka job/kafka-smoke -f
