-- Shared PostgreSQL instance: per-app databases and users
-- This runs automatically on first container start (empty pgdata volume).
-- To add a new app, add a block below and recreate the container
-- (or run the statements manually via psql).

-- OpenERA (Research Administration)
CREATE USER openera WITH PASSWORD 'openera_change_me';
CREATE DATABASE openera OWNER openera;

-- UCM Daily Register (Communications)
CREATE USER ucm WITH PASSWORD 'ucm_change_me';
CREATE DATABASE ucm_newsletter OWNER ucm;

-- Audit Dashboard (Internal Audit)
CREATE USER audit_user WITH PASSWORD 'audit_change_me';
CREATE DATABASE audit_dashboard OWNER audit_user;
