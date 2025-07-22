#!/bin/bash
set -e

cd "${ML_WORKSPACE_ROOT}/ml-infra" || {
  echo "Failed to cd into ml-infra repo."
  exit 1
}

terraform init
terraform apply -auto-approve
