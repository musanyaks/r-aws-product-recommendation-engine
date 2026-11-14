#!/usr/bin/env bash
# aws/local/init.sh — provision floci with the same resources as prod
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

aws --endpoint-url http://localhost:4566 s3 mb s3://reco-engine-local
aws --endpoint-url http://localhost:4566 secretsmanager create-secret \
  --name reco/db-password --secret-string localpw
aws --endpoint-url http://localhost:4566 secretsmanager create-secret \
  --name reco/api-key --secret-string dev-key-change-me
