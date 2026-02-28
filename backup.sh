#!/usr/bin/env bash
# Backup all databases in the shared postgres instance.
# Usage: ./backup.sh
# Output: insight-db-backup-YYYY-MM-DD.sql.gz in the current directory.

set -euo pipefail

TIMESTAMP=$(date +%Y-%m-%d)
BACKUP_FILE="insight-db-backup-${TIMESTAMP}.sql.gz"

echo "Backing up all databases to ${BACKUP_FILE}..."
docker compose exec -T postgres pg_dumpall -U postgres | gzip > "${BACKUP_FILE}"
echo "Done. Size: $(du -h "${BACKUP_FILE}" | cut -f1)"
