# ──────────────────────────────────────────────────────────────────────────────
# PostgreSQL 17 + pgvector — lightweight Alpine image
# Build:  docker build -t pgvectordb .
# Run:    docker compose up -d
#
# Multi-stage build: compile pgvector in a builder stage, then copy only
# the shared library and SQL files into a pristine postgres:alpine image.
# JIT bitcode is skipped — it requires the exact LLVM version PG was built
# with and provides negligible benefit for pgvector workloads.
# ──────────────────────────────────────────────────────────────────────────────

ARG PG_VERSION=17
ARG PGVECTOR_VERSION=0.8.7

# ── Builder ─────────────────────────────────────────────────────────────────
FROM postgres:${PG_VERSION}-alpine AS builder

ARG PGVECTOR_VERSION

RUN apk add --no-cache build-base git \
    && git clone --branch v${PGVECTOR_VERSION} --depth 1 \
        https://github.com/pgvector/pgvector.git /tmp/pgvector

WORKDIR /tmp/pgvector

# Build the shared library (vector.so). This succeeds before the bitcode
# step, so `make || true` lets the build continue past the LLVM error.
# Then install manually — only .so + SQL files are needed at runtime.
RUN make OPTFLAGS="" || true \
    && install -D -m 755 vector.so /usr/local/lib/postgresql/vector.so \
    && install -D -m 644 vector.control /usr/local/share/postgresql/extension/vector.control \
    && for f in sql/vector--*.sql; do \
        install -D -m 644 "$f" "/usr/local/share/postgresql/extension/$(basename "$f")"; \
    done

# ── Runtime ────────────────────────────────────────────────────────────────
FROM postgres:${PG_VERSION}-alpine

COPY --from=builder /usr/local/lib/postgresql/vector.so /usr/local/lib/postgresql/vector.so
COPY --from=builder /usr/local/share/postgresql/extension/vector.control /usr/local/share/postgresql/extension/vector.control
COPY --from=builder /usr/local/share/postgresql/extension/vector--*.sql /usr/local/share/postgresql/extension/