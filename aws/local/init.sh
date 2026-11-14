#!/usr/bin/env bash
set -e

echo "Provisioning floci AWS resources..."

# S3 bucket for model artifacts
aws --endpoint-url=http://localhost:4566 s3 mb s3://reco-engine-local || true

# Secrets
aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name reco/db-password --secret-string "${DB_PASSWORD:-localpw}" || true

aws --endpoint-url=http://localhost:4566 secretsmanager create-secret \
  --name reco/api-key --secret-string "${API_KEY:-dev-key-change-me}" || true

echo "Floci provisioning complete."