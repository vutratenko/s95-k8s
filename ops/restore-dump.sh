#!/usr/bin/env bash
set -euo pipefail

DUMP="${1:-/home/vv.utratenko/Projects/dayly.dump}"
NAMESPACE="${NAMESPACE:-s95}"
POD="${POD:-s95-db-0}"

if [[ ! -f "${DUMP}" ]]; then
  echo "Dump not found: ${DUMP}" >&2
  exit 1
fi

echo "Waiting for ${POD}..."
kubectl wait --for=condition=Ready "pod/${POD}" -n "${NAMESPACE}" --timeout=600s

echo "Copying dump..."
kubectl cp "${DUMP}" "${NAMESPACE}/${POD}:/tmp/dayly.dump"

echo "Restoring..."
kubectl exec -n "${NAMESPACE}" "${POD}" -- \
  pg_restore -U postgres -d s95 --no-owner --no-acl -Fc /tmp/dayly.dump

echo "Granting privileges to s95 user..."
kubectl exec -n "${NAMESPACE}" "${POD}" -- psql -U postgres -d s95 -c \
  "GRANT ALL ON ALL TABLES IN SCHEMA public TO s95; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO s95;"

echo "Done. Run migrations: kubectl apply -f deploy/migrate-job.yaml"
