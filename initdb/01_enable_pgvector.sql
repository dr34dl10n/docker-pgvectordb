-- ──────────────────────────────────────────────────────────────────────────
-- Enable pgvector extension in the default database
-- Runs on first container initialisation only
-- ──────────────────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS vector;