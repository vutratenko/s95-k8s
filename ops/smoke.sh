#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-s95.sion2k.ru}"
NAMESPACE="${NAMESPACE:-s95}"

echo "== Pods =="
kubectl get pods -n "${NAMESPACE}"

echo
echo "== Services =="
kubectl get svc -n "${NAMESPACE}"

echo
echo "== Ingress =="
kubectl get ingress -n "${NAMESPACE}"

echo
echo "== Health check (in-cluster) =="
kubectl run s95-smoke-curl --rm -i --restart=Never -n "${NAMESPACE}" \
  --image=curlimages/curl:8.5.0 -- \
  curl -sf "http://s95-web:3000/up" && echo "OK /up"

echo
echo "== External health (if DNS ready) =="
curl -sf "https://${HOST}/up" && echo "OK https://${HOST}/up" || echo "SKIP external (DNS/TLS not ready)"

echo
echo "== Sidekiq pod =="
kubectl get pods -n "${NAMESPACE}" -l app.kubernetes.io/component=sidekiq

echo
echo "== CronJobs =="
kubectl get cronjobs -n "${NAMESPACE}"
