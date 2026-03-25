# Contributing to insight-db

Thank you for helping maintain `insight-db`, the shared PostgreSQL infrastructure
repository for the UI Insight application portfolio.

## Quick Start

1. Create a branch from `main`
2. Make the smallest change that keeps shared database operations clear and safe
3. Update documentation in the same change whenever runtime behavior or
   onboarding expectations move
4. Validate locally before opening a pull request
5. Open a pull request with a concise summary of operational impact

## What Changes Belong Here

This repository owns:

- Shared PostgreSQL container wiring
- Bootstrap role and database creation in `init/`
- Shared backup and restore guidance
- Cross-project database naming and onboarding documentation

This repository does not own:

- Application schemas, migrations, or table-level seed data
- Per-application runtime business logic
- Secrets for deployed environments

## Required Updates for Consumer Changes

When adding, renaming, or retiring an application database, update all of the
following in the same pull request:

- [README.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/README.md)
- [init/01-create-databases.sql](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/init/01-create-databases.sql)
- [.env.example](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/.env.example) if connection guidance changes
- The affiliated application repository documentation or deployment config

Because bootstrap SQL only runs automatically on first startup with an empty
volume, document any required replay steps for existing deployments.

## Validation

Before opening a pull request, run the checks that apply to your change:

```bash
docker compose config
```

If you changed the bootstrap SQL, also review it for idempotency and verify that
it remains safe to replay against an existing instance after credential updates.

If you changed operational shell scripts, run them through `shellcheck` when it
is available in your environment.

## Operational Expectations

- Never commit live database passwords, API keys, or `.env` files
- Treat backup files as sensitive operational artifacts
- Prefer explicit production and development database names
- Keep affiliated project docs in sync so deploy-time DSNs do not drift
- Call out operationally significant changes in the pull request description

## Code of Conduct

All participants are expected to follow the
[Code of Conduct](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/CODE_OF_CONDUCT.md).
