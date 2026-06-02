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

Any `.sql` or `.sh` file in `initdb/` runs on **first container start only** (standard PostgreSQL behaviour). The default `01_enable_pgvector.sql` creates the `vector` extension.

Add your own schemas, tables, or seed data as numbered files:

```
initdb/
├── 01_enable_pgvector.sql
├── 02_create_tables.sql      ← add your own
└── 03_seed_data.sql          ← add your own
```

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