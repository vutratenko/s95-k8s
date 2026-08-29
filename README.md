# s95-k8s — GitOps manifests for Sat_9am_5km

Kubernetes deployment for [Sat_9am_5km](https://github.com/vutratenko/Sat_9am_5km) on a personal stand (`s95.sion2k.ru`).

## Layout

| Path | Purpose |
|------|---------|
| `argocd/` | Argo CD Application |
| `postgres/` | Zalando PostgreSQL CR |
| `redis/`, `memcached/` | Supporting services |
| `deploy/` | Web, Sidekiq, Ingress, CronJobs, migrate Job |
| `secrets/` | Secret templates (no real values) |
| `ops/` | Restore dump, apply secrets, smoke tests |

## Quick start

1. Build and push app image from `Sat_9am_5km` (CI or local `docker build`).
2. Update image tag in `deploy/kustomization.yaml`.
3. Create secrets: see [secrets/README.md](secrets/README.md) and [ops/apply-secrets.sh](ops/apply-secrets.sh).
4. Apply Argo Application: [ops/apply-argocd.sh](ops/apply-argocd.sh).
5. Restore database: [ops/restore.md](ops/restore.md).
6. Smoke test: [ops/smoke.sh](ops/smoke.sh).

## Image

```
registry.sion2k.ru/s95/web:<git-sha>
```

Built by `.github/workflows/docker.yml` in the app repository.
