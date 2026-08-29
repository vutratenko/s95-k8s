# Database restore from dayly.dump

One-time procedure after Postgres CR is Ready. **Do not commit the dump to git.**

## Prerequisites

- `kubectl` access to cluster
- Dump file locally (e.g. `/home/vv.utratenko/Projects/dayly.dump`)
- Postgres pod running: `s95-db-0` in namespace `s95`

## 1. Wait for Postgres

```bash
kubectl wait --for=condition=Ready pod/s95-db-0 -n s95 --timeout=600s
```

## 2. Copy dump into pod

```bash
DUMP=/home/vv.utratenko/Projects/dayly.dump
kubectl cp "${DUMP}" s95/s95-db-0:/tmp/dayly.dump
```

## 3. Restore

Zalando creates user `s95` and database `s95`. Restore as postgres superuser:

```bash
kubectl exec -n s95 s95-db-0 -- bash -c \
  'pg_restore -U postgres -d s95 --no-owner --no-acl -Fc /tmp/dayly.dump'
```

If role errors appear, recreate ownership:

```bash
kubectl exec -n s95 s95-db-0 -- psql -U postgres -d s95 -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO s95;"
kubectl exec -n s95 s95-db-0 -- psql -U postgres -d s95 -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO s95;"
```

## 4. Verify extensions

```bash
kubectl exec -n s95 s95-db-0 -- psql -U postgres -d s95 -c "\dx"
```

Expected: `pg_stat_statements`, `pg_trgm`, `plpgsql`.

## 5. Run migrations

Argo PostSync hook runs `s95-migrate` Job automatically. Manual run:

```bash
kubectl delete job s95-migrate -n s95 --ignore-not-found
kubectl apply -f deploy/migrate-job.yaml
kubectl wait --for=condition=complete job/s95-migrate -n s95 --timeout=600s
kubectl logs -n s95 job/s95-migrate
```

## 6. Sync Active Storage files

DB rows in `active_storage_blobs` point to keys under `storage/` on disk.  
Copy prod archive into the web pod PVC mount:

```bash
WEB_POD=$(kubectl get pod -n s95 -l app.kubernetes.io/component=web -o jsonpath='{.items[0].metadata.name}')
kubectl cp /path/to/prod/storage/. "s95/${WEB_POD}:/usr/src/app/storage/"
```

## Notes

- Dump metadata: PG 12.22 custom format, database `s95`, ~16 MB (2026-08-03).
- Target cluster runs PG 17 — restore via `pg_restore` is supported.
- Rotate prod-derived user passwords/tokens on the stand.
- First restore only on empty DB; re-run requires drop/recreate database.

## Troubleshooting

**Duplicate schema_migrations:** dump already includes migrations; `db:migrate` should no-op or apply only new ones.

**Connection refused from app:** wait for Zalando secret `s95.s95-db.credentials.postgresql.acid.zalan.do` to exist before syncing deploy manifests.

**Broken images on site:** incomplete `storage/` sync — see step 6.
