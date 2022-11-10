CREATE TABLE github_events (
  event VARCHAR NOT NULL,
  delivery UUID PRIMARY KEY,
  organization VARCHAR,
  repository VARCHAR,
  receipt TIMESTAMPTZ,
  payload JSONB NOT NULL
);
