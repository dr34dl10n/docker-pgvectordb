# pgvectordb

Lightweight PostgreSQL 17 + [pgvector](https://github.com/pgvector/pgvector) Docker image, ready for semantic search and AI workloads.

## Quick start

```bash
docker compose up -d
```

Connect:

```bash
psql -h localhost -U postgres -d codebase
# Password: postgres
```

Verify pgvector is active:

```sql
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';
```

## codebase-skill Integration

This container is the database backend for [codebase-skill](https://github.com/dr34dl10n/Codebase-Agent-Skill) (semantic code search for AI agents).

The schema is auto-initialized on first start via `initdb/02_codebase_skill_schema.sql`. Tables created:

| Table | Purpose |
|-------|---------|
| `code_chunks` | Code fragments with embeddings (768-dim vectors) |
| `projects` | Indexed repository metadata |

To deploy codebase-skill with this Docker database:

```bash
bash deploy.sh --docker
```

Or manually configure:

```bash
# .env or environment
CODEINDEX_DB_MODE=docker
CODEINDEX_DB_HOST=localhost
CODEINDEX_DB_PORT=5433
CODEINDEX_DB_NAME=codebase
CODEINDEX_DB_USER=postgres
CODEINDEX_DB_PASSWORD=postgres
```

If you already have the container running and need to initialize the codebase-skill schema manually:

```bash
docker exec -i pgvectordb psql -U postgres -d codebase < /path/to/codebase-skill/init_db.sql
```

## Configuration

### Environment variables

Default credentials are in `docker-compose.yml` for local development.  
For custom settings, copy `.env.example` to `.env` and adjust:

```bash
cp .env.example .env
```

Then reference them in the compose file:

```yaml
environment:
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB}
```

### Port

Change the host port in `docker-compose.yml` to avoid conflicts:

```yaml
ports:
  - "5433:5432"   # host:container
```

### Persistence

Data is stored in the `pgdata` named volume. To inspect it:

```bash
docker volume inspect pgvectordb_data
```

To reset all data:

```bash
docker compose down -v
```

### Init scripts

Any `.sql` or `.sh` file in `initdb/` runs on **first container start only** (standard PostgreSQL behaviour). The default scripts set up pgvector and the codebase-skill schema:

```
initdb/
├── 01_enable_pgvector.sql              — creates the vector extension
├── 02_codebase_skill_schema.sql        — creates tables + indexes + upsert function
└── 03_seed_data.sql                    ← add your own
```

Add your own schemas, tables, or seed data as numbered files.

## Build arguments

Override PostgreSQL or pgvector versions at build time:

```yaml
build:
  args:
    PG_VERSION: "17"
    PGVECTOR_VERSION: "0.8.0"
```

## Docker image

Pre-built images are available on GHCR:

```bash
docker pull ghcr.io/dr34dl10n/pgvectordb:latest
```

### Tags

| Tag | PG | pgvector | Base |
|-----|----|----------|------|
| `latest` | 17 | 0.8.0 | Alpine |

## License

MIT