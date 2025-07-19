#!/bin/bash

echo "Getting script directory of setup.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: $SCRIPT_DIR"

echo "Running setup.sh"
source "${SCRIPT_DIR}/setup.sh"

REPO_URL="https://github.com/Ben0112358/ml-infra.git"
TARGET_DIR="ml-infra"

echo "establish repo content locally"
clone_gh_repo_and_pull_latest "$REPO_URL" "$TARGET_DIR"

echo "Change working directory"
cd "${ML_HOMELAB_ROOT}/${TARGET_DIR}" || exit 1

echo "terraform init + apply"
terraform init
terraform apply -auto-approve
