#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ROOT="${APP_ROOT:-${ROOT}/../Sat_9am_5km}"
REGISTRY="${REGISTRY:-registry.sion2k.ru}"
IMAGE="${IMAGE:-${REGISTRY}/s95/web}"
TAG="${TAG:-latest}"

cd "${APP_ROOT}"
docker build -t "${IMAGE}:${TAG}" -f Dockerfile .
docker push "${IMAGE}:${TAG}"

echo "Pushed ${IMAGE}:${TAG}"
echo "Update deploy/kustomization.yaml newTag if not using latest."
