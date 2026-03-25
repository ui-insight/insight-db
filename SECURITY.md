# Security Policy

## Reporting a Vulnerability

If you discover a security issue in `insight-db`, please report it through
[GitHub's private vulnerability reporting flow](https://github.com/ui-insight/insight-db/security/advisories/new).

Do not open a public issue for security vulnerabilities.

## What to Include

- A description of the issue and potential impact
- Steps to reproduce or validate the risk
- Affected files, configuration paths, or deployment steps
- Any suggested mitigations, if available

## Supported Versions

`insight-db` is maintained on the `main` branch. There are no separately
maintained release branches at this time.

## Operational Security Notes

- Rotate all placeholder passwords in
  [init/01-create-databases.sql](/Users/barrierobison/Documents/Administration/AICoordination2026/insight-db/init/01-create-databases.sql)
  before first startup
- If replaying the bootstrap SQL against an existing instance, confirm the
  resulting credential rotation is intentional before running it
- Never commit real secrets or `.env` files to version control
- Treat `pg_dumpall` backups as sensitive because they may contain data from
  multiple affiliated applications
- Limit application access to the shared `insight-db-net` network and provision
  only the roles and databases each consumer needs

## Known Limitations

- The bootstrap SQL contains placeholder passwords by design; secure deployment
  depends on replacing them before use
- `backup.sh` produces an unencrypted logical dump; encryption and off-host
  retention policies must be handled by the deployment environment
- This repo provisions databases and roles, but application-level schema review
  and data validation remain the responsibility of the consumer repositories
