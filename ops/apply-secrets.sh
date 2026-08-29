#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-s95}"
ENV_FILE="${1:-secrets/s95-app-secrets.env}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy from secrets/s95-app-secrets.env.example" >&2
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic s95-app-secrets \
  --namespace "${NAMESPACE}" \
  --from-env-file="${ENV_FILE}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Applied secret s95-app-secrets in namespace ${NAMESPACE}"
