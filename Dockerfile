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
ARG PGVECTOR_VERSION=0.8.0

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
    && install -D -m 644 sql/vector--0.1.0--0.1.1.sql /usr/local/share/postgresql/extension/vector--0.1.0--0.1.1.sql \
    && install -D -m 644 sql/vector--0.1.1--0.1.3.sql /usr/local/share/postgresql/extension/vector--0.1.1--0.1.3.sql \
    && install -D -m 644 sql/vector--0.1.3--0.1.4.sql /usr/local/share/postgresql/extension/vector--0.1.3--0.1.4.sql \
    && install -D -m 644 sql/vector--0.1.4--0.1.5.sql /usr/local/share/postgresql/extension/vector--0.1.4--0.1.5.sql \
    && install -D -m 644 sql/vector--0.1.5--0.1.6.sql /usr/local/share/postgresql/extension/vector--0.1.5--0.1.6.sql \
    && install -D -m 644 sql/vector--0.1.6--0.1.7.sql /usr/local/share/postgresql/extension/vector--0.1.6--0.1.7.sql \
    && install -D -m 644 sql/vector--0.1.7--0.1.8.sql /usr/local/share/postgresql/extension/vector--0.1.7--0.1.8.sql \
    && install -D -m 644 sql/vector--0.1.8--0.2.0.sql /usr/local/share/postgresql/extension/vector--0.1.8--0.2.0.sql \
    && install -D -m 644 sql/vector--0.2.0--0.2.1.sql /usr/local/share/postgresql/extension/vector--0.2.0--0.2.1.sql \
    && install -D -m 644 sql/vector--0.2.1--0.2.2.sql /usr/local/share/postgresql/extension/vector--0.2.1--0.2.2.sql \
    && install -D -m 644 sql/vector--0.2.2--0.2.3.sql /usr/local/share/postgresql/extension/vector--0.2.2--0.2.3.sql \
    && install -D -m 644 sql/vector--0.2.3--0.2.4.sql /usr/local/share/postgresql/extension/vector--0.2.3--0.2.4.sql \
    && install -D -m 644 sql/vector--0.2.4--0.2.5.sql /usr/local/share/postgresql/extension/vector--0.2.4--0.2.5.sql \
    && install -D -m 644 sql/vector--0.2.5--0.2.6.sql /usr/local/share/postgresql/extension/vector--0.2.5--0.2.6.sql \
    && install -D -m 644 sql/vector--0.2.6--0.2.7.sql /usr/local/share/postgresql/extension/vector--0.2.6--0.2.7.sql \
    && install -D -m 644 sql/vector--0.2.7--0.3.0.sql /usr/local/share/postgresql/extension/vector--0.2.7--0.3.0.sql \
    && install -D -m 644 sql/vector--0.3.0--0.3.1.sql /usr/local/share/postgresql/extension/vector--0.3.0--0.3.1.sql \
    && install -D -m 644 sql/vector--0.3.1--0.3.2.sql /usr/local/share/postgresql/extension/vector--0.3.1--0.3.2.sql \
    && install -D -m 644 sql/vector--0.3.2--0.4.0.sql /usr/local/share/postgresql/extension/vector--0.3.2--0.4.0.sql \
    && install -D -m 644 sql/vector--0.4.0--0.4.1.sql /usr/local/share/postgresql/extension/vector--0.4.0--0.4.1.sql \
    && install -D -m 644 sql/vector--0.4.1--0.4.2.sql /usr/local/share/postgresql/extension/vector--0.4.1--0.4.2.sql \
    && install -D -m 644 sql/vector--0.4.2--0.4.3.sql /usr/local/share/postgresql/extension/vector--0.4.2--0.4.3.sql \
    && install -D -m 644 sql/vector--0.4.3--0.4.4.sql /usr/local/share/postgresql/extension/vector--0.4.3--0.4.4.sql \
    && install -D -m 644 sql/vector--0.4.4--0.5.0.sql /usr/local/share/postgresql/extension/vector--0.4.4--0.5.0.sql \
    && install -D -m 644 sql/vector--0.5.0--0.5.1.sql /usr/local/share/postgresql/extension/vector--0.5.0--0.5.1.sql \
    && install -D -m 644 sql/vector--0.5.1--0.6.0.sql /usr/local/share/postgresql/extension/vector--0.5.1--0.6.0.sql \
    && install -D -m 644 sql/vector--0.6.0--0.6.1.sql /usr/local/share/postgresql/extension/vector--0.6.0--0.6.1.sql \
    && install -D -m 644 sql/vector--0.6.1--0.6.2.sql /usr/local/share/postgresql/extension/vector--0.6.1--0.6.2.sql \
    && install -D -m 644 sql/vector--0.6.2--0.7.0.sql /usr/local/share/postgresql/extension/vector--0.6.2--0.7.0.sql \
    && install -D -m 644 sql/vector--0.7.0--0.7.1.sql /usr/local/share/postgresql/extension/vector--0.7.0--0.7.1.sql \
    && install -D -m 644 sql/vector--0.7.1--0.7.2.sql /usr/local/share/postgresql/extension/vector--0.7.1--0.7.2.sql \
    && install -D -m 644 sql/vector--0.7.2--0.7.3.sql /usr/local/share/postgresql/extension/vector--0.7.2--0.7.3.sql \
    && install -D -m 644 sql/vector--0.7.3--0.7.4.sql /usr/local/share/postgresql/extension/vector--0.7.3--0.7.4.sql \
    && install -D -m 644 sql/vector--0.7.4--0.8.0.sql /usr/local/share/postgresql/extension/vector--0.7.4--0.8.0.sql \
    && install -D -m 644 sql/vector--0.8.0.sql /usr/local/share/postgresql/extension/vector--0.8.0.sql

# ── Runtime ────────────────────────────────────────────────────────────────
FROM postgres:${PG_VERSION}-alpine

COPY --from=builder /usr/local/lib/postgresql/vector.so /usr/local/lib/postgresql/vector.so
COPY --from=builder /usr/local/share/postgresql/extension/vector.control /usr/local/share/postgresql/extension/vector.control
COPY --from=builder /usr/local/share/postgresql/extension/vector--*.sql /usr/local/share/postgresql/extension/