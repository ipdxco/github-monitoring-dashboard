CREATE TABLE github_events (
  event VARCHAR NOT NULL,
  delivery UUID PRIMARY KEY,
  organization VARCHAR,
  repository VARCHAR,
  received_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  payload JSONB NOT NULL
);
