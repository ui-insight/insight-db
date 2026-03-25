-- Shared PostgreSQL instance: per-app databases and users
-- This runs automatically on first container start with an empty pgdata volume.
-- It is also safe to replay manually against an existing instance after updating
-- the bootstrap passwords below.
-- Bootstrapped here by default: OpenERA, UCM Daily Register, Audit Dashboard,
-- ProcessMapping, and ExecOrd. Other affiliated projects can be provisioned
-- manually when they adopt the shared Postgres runtime.

-- OpenERA (Research Administration)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'openera') THEN
        CREATE ROLE openera WITH LOGIN PASSWORD 'openera_dev';
    ELSE
        ALTER ROLE openera WITH LOGIN PASSWORD 'openera_dev';
    END IF;
END
$$;

SELECT 'CREATE DATABASE openera OWNER openera'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'openera')\gexec
SELECT 'CREATE DATABASE openera_dev OWNER openera'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'openera_dev')\gexec
GRANT ALL PRIVILEGES ON DATABASE openera TO openera;
GRANT ALL PRIVILEGES ON DATABASE openera_dev TO openera;

-- UCM Daily Register (Communications)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'ucm') THEN
        CREATE ROLE ucm WITH LOGIN PASSWORD 'ucm_change_me';
    ELSE
        ALTER ROLE ucm WITH LOGIN PASSWORD 'ucm_change_me';
    END IF;
END
$$;

SELECT 'CREATE DATABASE ucm_newsletter OWNER ucm'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'ucm_newsletter')\gexec
SELECT 'CREATE DATABASE ucm_newsletter_dev OWNER ucm'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'ucm_newsletter_dev')\gexec
GRANT ALL PRIVILEGES ON DATABASE ucm_newsletter TO ucm;
GRANT ALL PRIVILEGES ON DATABASE ucm_newsletter_dev TO ucm;

-- Audit Dashboard (Internal Audit)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'audit_user') THEN
        CREATE ROLE audit_user WITH LOGIN PASSWORD 'audit_change_me';
    ELSE
        ALTER ROLE audit_user WITH LOGIN PASSWORD 'audit_change_me';
    END IF;
END
$$;

SELECT 'CREATE DATABASE audit_dashboard OWNER audit_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'audit_dashboard')\gexec
SELECT 'CREATE DATABASE audit_dashboard_dev OWNER audit_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'audit_dashboard_dev')\gexec
GRANT ALL PRIVILEGES ON DATABASE audit_dashboard TO audit_user;
GRANT ALL PRIVILEGES ON DATABASE audit_dashboard_dev TO audit_user;

-- ProcessMapping (Research Administration)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'processmapping') THEN
        CREATE ROLE processmapping WITH LOGIN PASSWORD 'processmapping_dev';
    ELSE
        ALTER ROLE processmapping WITH LOGIN PASSWORD 'processmapping_dev';
    END IF;
END
$$;

SELECT 'CREATE DATABASE processmapping OWNER processmapping'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'processmapping')\gexec
SELECT 'CREATE DATABASE processmapping_dev OWNER processmapping'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'processmapping_dev')\gexec
GRANT ALL PRIVILEGES ON DATABASE processmapping TO processmapping;
GRANT ALL PRIVILEGES ON DATABASE processmapping_dev TO processmapping;

-- ExecOrd (Executive Orders Tracking)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'execord') THEN
        CREATE ROLE execord WITH LOGIN PASSWORD 'execord_dev';
    ELSE
        ALTER ROLE execord WITH LOGIN PASSWORD 'execord_dev';
    END IF;
END
$$;

SELECT 'CREATE DATABASE execord OWNER execord'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'execord')\gexec
SELECT 'CREATE DATABASE execord_dev OWNER execord'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'execord_dev')\gexec
GRANT ALL PRIVILEGES ON DATABASE execord TO execord;
GRANT ALL PRIVILEGES ON DATABASE execord_dev TO execord;
