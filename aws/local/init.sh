#!/usr/bin/env bash
set -euo pipefail

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

ENDPOINT="${AWS_ENDPOINT_URL:-http://localhost:4566}"
awsl() { aws --endpoint-url="$ENDPOINT" "$@"; }

echo "Waiting for floci at $ENDPOINT..."
for i in $(seq 1 30); do
  if awsl s3api list-buckets >/dev/null 2>&1; then break; fi
  if [ "$i" -eq 30 ]; then echo "floci not reachable after 30s" >&2; exit 1; fi
  sleep 1
done

echo "Provisioning floci AWS resources..."

if ! awsl s3api head-bucket --bucket reco-engine-local 2>/dev/null; then
  awsl s3 mb s3://reco-engine-local
fi

create_secret() {
  if ! awsl secretsmanager describe-secret --secret-id "$1" >/dev/null 2>&1; then
    awsl secretsmanager create-secret --name "$1" --secret-string "$2" >/dev/null
  fi
}
create_secret reco/db-password "${DB_PASSWORD:-localpw}"
create_secret reco/api-key "${API_KEY:-dev-key-change-me}"

MODEL="${MODEL_FILE:-/models/model.rds}"
if [ -f "$MODEL" ]; then
  awsl s3 cp "$MODEL" s3://reco-engine-local/models/model.rds
fi

echo "Floci provisioning complete."
