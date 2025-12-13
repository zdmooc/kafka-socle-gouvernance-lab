#!/usr/bin/env bash
set -euo pipefail

NS="${1:-kafka}"
OUT="${2:-report-weekly.md}"
NOW="$(date -Is)"

{
  echo "# Reporting hebdomadaire – Kafka"
  echo
  echo "Généré: $NOW"
  echo
  echo "## État cluster"
  kubectl -n "$NS" get kafka,kafkanodepool 2>/dev/null || true
  echo
  echo "## Pods (kafka + operator)"
  kubectl -n "$NS" get pods -o wide 2>/dev/null || true
  echo
  echo "## Events récents"
  kubectl -n "$NS" get events --sort-by=.lastTimestamp | tail -n 30 2>/dev/null || true
  echo
  echo "## Topics (CRs)"
  kubectl -n "$NS" get kafkatopics 2>/dev/null || true
  echo
  echo "## Users (CRs)"
  kubectl -n "$NS" get kafkausers 2>/dev/null || true
} > "$OUT"

echo "Report written to $OUT"
