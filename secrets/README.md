# Application secrets (do not commit real values)

Copy `s95-app-secrets.env.example` to `s95-app-secrets.env`, fill in values, then run:

```bash
./ops/apply-secrets.sh
```

## Required keys

| Key | Source |
|-----|--------|
| `RAILS_MASTER_KEY` | prod `config/master.key` |
| `BOT_TOKEN` | Telegram bot token |
| `DEV_TELEGRAM_ID` | Dev/admin Telegram user id |
| `VK_TOKEN`, `VK_GROUP_ID`, `VK_ALBUM_ID` | VK API |
| `YANDEX_MAPS_API_KEY` | Yandex Maps |
| `ROLLBAR_ACCESS_TOKEN` | Rollbar |
| `PROMETHEUS_TOKEN` | `/metrics` auth |
| `ADMIN_EMAIL`, `INFO_EMAIL` | Site contact emails |

## Database credentials

Provided automatically by Zalando operator secret  
`s95.s95-db.credentials.postgresql.acid.zalan.do` — do not duplicate in `s95-app-secrets`.

## Rails credentials (mailer, ParkZhrun)

Encrypted in `credentials.yml.enc`; decrypted via `RAILS_MASTER_KEY` only.

## Static files (optional)

Copy from prod Capistrano shared dir into PVC:

- `public/app-release.apk`
- `public/images/hero-bg.webp`

```bash
kubectl cp public/app-release.apk s95/$(kubectl get pod -n s95 -l app.kubernetes.io/component=web -o name | head -1 | cut -d/ -f2):/usr/src/app/public/app-release.apk
```

## Active Storage

Restore DB references blobs under `storage/`. Sync archive from prod:

```bash
kubectl cp storage/. s95/$(kubectl get pod -n s95 -l app.kubernetes.io/component=web -o name | head -1 | cut -d/ -f2):/usr/src/app/storage/
```

## Registry pull secret

If needed, create `registry-sion2k-pull` in namespace `s95` (copy from another namespace):

```bash
kubectl get secret registry-sion2k-pull -n chem-ya-krasila -o yaml | \
  sed 's/namespace: chem-ya-krasila/namespace: s95/' | \
  kubectl apply -f -
```

## additional_events.yml

Default example is in `deploy/configmap-additional-events.yaml`.  
Override by editing the ConfigMap or replacing with prod content before sync.
