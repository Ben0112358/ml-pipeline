#!/bin/bash
set -e

cd "${ML_WORKSPACE_ROOT}/ml-infra" || {
	echo "Failed to cd into ml-infra repo."
	exit 1
}

terraform init
terraform apply -auto-approve

terraform output -json | jq -r '
  to_entries
  | map(select(.key | test("^[A-Z_]+$")))
  | map("\(.key)=\"\(.value.value|tostring)\"")
  | .[]
' > "${ML_HOMELAB_ROOT}/.terraform_envs"
