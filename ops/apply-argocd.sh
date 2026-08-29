#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "${ROOT}/argocd/application.yaml"
echo "Argo CD Application s95 applied."
echo "Open Argo UI or run: kubectl get application s95 -n shturval-cd"
