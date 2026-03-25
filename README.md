# Insight DB — Shared PostgreSQL Instance

Single PostgreSQL 16 container serving UI Insight applications on the shared VM. Each application gets its own database and credentials while sharing the same Docker network entrypoint: `insight-db` on `insight-db-net`.

## Prerequisites

Create the shared Docker network (once, on the host):

```bash
docker network create --subnet=10.20.0.0/24 insight-db-net
```

## Quick Start

```bash
cp .env.example .env
# Edit .env — set POSTGRES_PASSWORD
# Edit init/01-create-databases.sql — rotate per-app bootstrap passwords

docker compose up -d
```

After startup, confirm the container is healthy:

```bash
docker compose ps
docker compose exec postgres pg_isready -U postgres
```

## Databases (Bootstrapped by Default)

The default init script creates production and development databases for OpenERA, UCM Daily Register, Audit Dashboard, ProcessMapping, and ExecOrd.

Important: this bootstrap only runs automatically on first startup with an empty `pgdata` volume. If you added this repo to an existing deployment, new databases introduced by later commits must be provisioned manually.

| Database | User | Application | Environment |
|---|---|---|---|
| `openera` | `openera` | OpenERA | Production |
| `openera_dev` | `openera` | OpenERA | Development |
| `ucm_newsletter` | `ucm` | UCM Daily Register | Production |
| `ucm_newsletter_dev` | `ucm` | UCM Daily Register | Development |
| `audit_dashboard` | `audit_user` | Audit Dashboard | Production |
| `audit_dashboard_dev` | `audit_user` | Audit Dashboard | Development |
| `processmapping` | `processmapping` | ProcessMapping | Production |
| `processmapping_dev` | `processmapping` | ProcessMapping | Development |
| `execord` | `execord` | ExecOrd | Production |
| `execord_dev` | `execord` | ExecOrd | Development |

## Verified Integrations

The integration notes below were checked against the `main` branch configuration
of the affiliated application repositories on March 25, 2026.

| Application | Status | Connection Style | Production DB | Development DB | Notes |
|---|---|---|---|---|---|
| OpenERA | Active | `DATABASE_URL` | `openera` | `openera_dev` | `docker-compose.yml` joins `insight-db-net`; default compose value points at `openera`, so non-production stacks should override `DATABASE_URL` explicitly |
| UCM Daily Register | Active | `DATABASE_URL` | `ucm_newsletter` | `ucm_newsletter_dev` | Backend joins `insight-db-net`; deployment config expects the DSN to come from the app repo's `.env` file |
| Audit Dashboard | Active | `DATABASE_URL` | `audit_dashboard` | `audit_dashboard_dev` | Compose profiles pin separate production and development databases on the shared host |
| ProcessMapping | Active optional overlay | `INSIGHT_DB_DSN` or `INSIGHT_DB_*` | `processmapping` | `processmapping_dev` | `docker-compose.insight-db.yml` joins `insight-db-net` and defaults DB-backed runtime to `processmapping_dev` |
| ExecOrd | Active | `DATABASE_URL` | `execord` | `execord_dev` | Backend joins `insight-db-net`; DSN set via app repo `.env`; includes MindRouter AI integration for document analysis |
| StratPlan Tactics | Supported, not enabled by default | `INSIGHT_DB_DSN` or `INSIGHT_DB_*` | `stratplan` | `stratplan_dev` | Repo supports `DATA_SOURCE=insight_db`, but its default `docker-compose.yml` does not join `insight-db-net`; provision manually when adopting shared Postgres |

`insight-db` is not the schema source of truth for those applications. App-level
tables, migrations, and seed data remain owned by the individual consumer
repositories; this repo owns only the shared PostgreSQL host, bootstrap roles,
database creation, and shared operations guidance.

## Existing Deployment Upgrade Notes

If your shared Postgres container was initialized before March 25, 2026, ExecOrd objects (and ProcessMapping if before March 8) will not exist automatically. The bootstrap SQL in [init/01-create-databases.sql](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/init/01-create-databases.sql) is idempotent, so after updating passwords you can safely replay it against an existing instance:

```bash
docker compose exec -T postgres psql -U postgres < init/01-create-databases.sql
```

Useful verification commands:

```bash
docker compose exec postgres psql -U postgres -lqt
docker compose exec postgres psql -U postgres -c "\\du"
```

## StratPlan Tactics (Optional `insight_db` Runtime)

`StratPlanTacticsMB` supports `DATA_SOURCE=insight_db` mode and can use this shared Postgres instance.
A StratPlan database is not bootstrapped by default; create it when enabling DB-backed runtime:

```bash
docker compose exec postgres psql -U postgres -c "CREATE USER stratplan WITH PASSWORD 'stratplan_change_me';"
docker compose exec postgres psql -U postgres -c "CREATE DATABASE stratplan OWNER stratplan;"
docker compose exec postgres psql -U postgres -c "CREATE DATABASE stratplan_dev OWNER stratplan;"
```

Example app settings:

- `DATA_SOURCE=insight_db`
- `INSIGHT_DB_DSN=postgresql://stratplan:<password>@insight-db:5432/stratplan` (preferred), or:
- `INSIGHT_DB_HOST=insight-db`
- `INSIGHT_DB_PORT=5432`
- `INSIGHT_DB_NAME=stratplan`
- `INSIGHT_DB_USER=stratplan`
- `INSIGHT_DB_PASSWORD=<password>`
- Optional: `INSIGHT_DB_SSLMODE=<mode>`
- Optional: `INSIGHT_DB_CONNECT_TIMEOUT_SECONDS=<seconds>`

## Adding a New Application

1. Add an idempotent role/database block to [init/01-create-databases.sql](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/init/01-create-databases.sql)
2. If the container already has data, replay that file with `docker compose exec -T postgres psql -U postgres < init/01-create-databases.sql`
3. In the new app's `docker-compose.yml`, add `insight-db-net` as an external network on the backend service
4. Prefer a single explicit connection setting in the app repo:
   `DATABASE_URL=postgresql+asyncpg://...` for SQLAlchemy/FastAPI apps, or `INSIGHT_DB_DSN` / `INSIGHT_DB_*` for projection-style runtimes
5. Document the assigned production and development database names in both repos so deploys do not drift

## Governance

This repository now includes the baseline governance artifacts used elsewhere in
the UI Insight portfolio:

- [GOVERNANCE.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/GOVERNANCE.md) for ownership, change control, and scope
- [CONTRIBUTING.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/CONTRIBUTING.md) for contribution expectations
- [SECURITY.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/SECURITY.md) for responsible disclosure and operational security notes
- [CODE_OF_CONDUCT.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/CODE_OF_CONDUCT.md) for contributor behavior standards
- [.github/CODEOWNERS](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/.github/CODEOWNERS) for review ownership

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

No database container is needed in each application stack — all apps share this single PostgreSQL instance.

### Common DSN Patterns

```text
OpenERA prod:         postgresql+asyncpg://openera:<password>@insight-db:5432/openera
OpenERA dev/staging:  postgresql+asyncpg://openera:<password>@insight-db:5432/openera_dev
UCM prod:             postgresql+asyncpg://ucm:<password>@insight-db:5432/ucm_newsletter
UCM dev:              postgresql+asyncpg://ucm:<password>@insight-db:5432/ucm_newsletter_dev
Audit prod:           postgresql+asyncpg://audit_user:<password>@insight-db:5432/audit_dashboard
Audit dev:            postgresql+asyncpg://audit_user:<password>@insight-db:5432/audit_dashboard_dev
ProcessMapping prod:  postgresql://processmapping:<password>@insight-db:5432/processmapping
ProcessMapping dev:   postgresql://processmapping:<password>@insight-db:5432/processmapping_dev
ExecOrd prod:         postgresql+asyncpg://execord:<password>@insight-db:5432/execord
ExecOrd dev:          postgresql+asyncpg://execord:<password>@insight-db:5432/execord_dev
StratPlan prod:       postgresql://stratplan:<password>@insight-db:5432/stratplan
StratPlan dev:        postgresql://stratplan:<password>@insight-db:5432/stratplan_dev
```

## Day-2 Operations

List databases:

```bash
docker compose exec postgres psql -U postgres -lqt
```

Open a SQL shell:

```bash
docker compose exec postgres psql -U postgres
```

Restore a backup created by [backup.sh](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/backup.sh):

```bash
gunzip -c insight-db-backup-YYYY-MM-DD.sql.gz | docker compose exec -T postgres psql -U postgres
```
