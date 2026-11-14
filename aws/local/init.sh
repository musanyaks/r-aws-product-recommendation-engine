#!/usr/bin/env bash
set -euo pipefail

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

ENDPOINT="${AWS_ENDPOINT_URL:-http://localhost:4566}"
awsl() { aws --endpoint-url="$ENDPOINT" "$@"; }

echo "Waiting for floci at $ENDPOINT..."
for i in $(seq 1 30); do
  curl -fs "$ENDPOINT" >/dev/null 2>&1 && break
  [ "$i" -eq 30 ] && { echo "floci not reachable after 30s" >&2; exit 1; }
  sleep 1
done

echo "Provisioning floci AWS resources..."

# S3 bucket for model artifacts (skip if it exists)
awsl s3api head-bucket --bucket reco-engine-local 2>/dev/null \
  || awsl s3 mb s3://reco-engine-local

# Secrets (skip if they exist)
create_secret() {
  awsl secretsmanager describe-secret --secret-id "$1" >/dev/null 2>&1 \
    || awsl secretsmanager create-secret --name "$1" --secret-string "$2" >/dev/null
}
create_secret reco/db-password "${DB_PASSWORD:-localpw}"
create_secret reco/api-key "${API_KEY:-dev-key-change-me}"

echo "Floci provisioning complete."