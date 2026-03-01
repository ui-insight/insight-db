# Insight DB — Shared PostgreSQL Instance

Single PostgreSQL 16 container serving all UI Insight applications on the shared VM. Each application gets its own database and credentials.

## Prerequisites

Create the shared Docker network (once, on the host):

```bash
docker network create --subnet=10.20.0.0/24 insight-db-net
```

## Quick Start

```bash
cp .env.example .env
# Edit .env — set POSTGRES_PASSWORD
# Edit init/01-create-databases.sql — set per-app passwords

docker compose up -d
```

## Databases

Each application has a production and development database, both owned by the same user.

| Database | User | Application | Environment |
|---|---|---|---|
| `openera` | `openera` | OpenERA | Production |
| `openera_dev` | `openera` | OpenERA | Development |
| `ucm_newsletter` | `ucm` | UCM Daily Register | Production |
| `ucm_newsletter_dev` | `ucm` | UCM Daily Register | Development |
| `audit_dashboard` | `audit_user` | Audit Dashboard | Production |
| `audit_dashboard_dev` | `audit_user` | Audit Dashboard | Development |

## Adding a New Application

1. Add `CREATE USER` and `CREATE DATABASE` to `init/01-create-databases.sql`
2. If the container already has data, run the statements manually:
   ```bash
   docker compose exec postgres psql -U postgres -c "CREATE USER myapp WITH PASSWORD 'secret';"
   docker compose exec postgres psql -U postgres -c "CREATE DATABASE myapp OWNER myapp;"
   ```
3. In the new app's `docker-compose.yml`, add `insight-db-net` as an external network on the backend service

## Backups

```bash
./backup.sh
# Creates insight-db-backup-YYYY-MM-DD.sql.gz
```

## Connecting

From any container on the `insight-db-net` network:

```
postgresql+asyncpg://[USER]:[PASSWORD]@insight-db:5432/[DATABASE]
```

The container name is `insight-db`, which Docker DNS resolves on the shared network.

### Connecting an Application

Applications connect by joining the `insight-db-net` external network in their own `docker-compose.yml`:

```yaml
services:
  backend:
    networks:
      - app-net
      - insight-db-net
    environment:
      - DATABASE_URL=postgresql+asyncpg://openera:${DB_PASSWORD}@insight-db:5432/openera

networks:
  app-net:
    driver: bridge
  insight-db-net:
    external: true
```

No database container is needed in the application stack — all apps share this single PostgreSQL instance.
