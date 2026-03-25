# Governance

`insight-db` is the infrastructure repository for the shared PostgreSQL host
used by multiple UI Insight applications.

## Repository Scope

This repository is the source of truth for:

- Shared PostgreSQL container configuration
- Bootstrap role and database creation
- Shared network expectations for consumer applications
- Backup and restore operating guidance
- Cross-project database naming conventions

This repository is not the source of truth for:

- Application tables, migrations, or ORM models
- App-specific seed data
- App-specific deployment secrets
- Application authorization and business rules

Those responsibilities stay with the affiliated consumer repositories.

## Decision-Making

- Infrastructure and operational documentation changes go through pull request review
- Changes to `init/`, `docker-compose.yml`, `backup.sh`, `.env.example`, or security policy are treated as operationally sensitive
- Any change that adds a new application database must update both this repo and the affiliated application repo documentation before merge

## Change Control

Because bootstrap SQL runs automatically only on first startup with an empty
`pgdata` volume, changes that add or alter databases must include:

- Idempotent SQL suitable for replay on existing deployments
- Upgrade notes in [README.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/README.md) when existing instances require manual action
- Clear production and development database naming

## Data Responsibility

This repository stores infrastructure code and documentation, not operational
application data. However, deployed `insight-db` instances and backup artifacts
may contain institutional data from downstream applications.

Operational rule of thumb:

- Treat backups as sensitive
- Apply the highest applicable downstream data-handling requirement when data
  from multiple apps is co-located
- Do not commit runtime dumps or exported records to this repository

## Ownership and Review

Code ownership is defined in
[.github/CODEOWNERS](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/.github/CODEOWNERS).
The default owner for this repository is `@ui-insight`.

## Related Policies

- [CONTRIBUTING.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/CONTRIBUTING.md)
- [SECURITY.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/SECURITY.md)
- [CODE_OF_CONDUCT.md](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/CODE_OF_CONDUCT.md)
