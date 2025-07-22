#!/bin/bash

set -euo pipefail

mkdir -p "$ML_WORKSPACE_ROOT"

prepare_repo() {
    local gh_repo_clone_url="$1"
    local gh_repo_folder_name="$2"
    local mode="${3:-dev}"

    local target_dir="$ML_WORKSPACE_ROOT/$gh_repo_folder_name"

    echo "Preparing repo: $gh_repo_folder_name (mode: $mode)"

    if [[ "$mode" == "prod" ]]; then
        if [[ -d "$target_dir" ]]; then
            echo "Repo $gh_repo_folder_name already exists, skipping clone."
        else
            git clone "$gh_repo_clone_url" "$target_dir"
        fi
    else
        if [[ ! -d "$ML_HOMELAB_ROOT/$gh_repo_folder_name" ]]; then
            echo "Error: "$ML_HOMELAB_ROOT"/$gh_repo_folder_name not found on host."
            exit 1
        fi
        rm -rf "$target_dir"
        cp -r "$ML_HOMELAB_ROOT/$gh_repo_folder_name" "$target_dir"
    fi
}

MODE="${1:-dev}"

prepare_repo "https://github.com/Ben0112358/ml-infra.git" "ml-infra" "$MODE"
prepare_repo "https://github.com/Ben0112358/ml-data.git" "ml-data" "$MODE"
prepare_repo "https://github.com/Ben0112358/ml-training.git" "ml-training" "$MODE"
prepare_repo "https://github.com/Ben0112358/ml-serving.git" "ml-serving" "$MODE"
prepare_repo "https://github.com/Ben0112358/ml-ui.git" "ml-ui" "$MODE"
