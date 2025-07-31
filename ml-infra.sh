#!/bin/bash
set -euo pipefail

source ./utils.sh

cd "${ML_WORKSPACE_ROOT}/ml-infra" || {
	log "ERROR" "Failed to cd into ml-infra repo."
	exit 1
}

log "INFO" "Terraform init & apply"
terraform init
terraform apply -auto-approve

log "INFO" "Make env vars out of terraform UPPER CASE outputs."
terraform output -json | jq -r '
  to_entries
  | map(select(.key | test("^[A-Z_]+$")))
  | map("\(.key)=\"\(.value.value|tostring)\"")
  | .[]
' >"${ML_HOMELAB_ROOT}/.terraform_envs"
