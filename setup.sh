#!/bin/bash

set -e

if [[ -z "${ML_HOMELAB_ROOT}" ]]; then
	echo "Error: ML_HOMELAB_ROOT environment variable is not set."
	exit 1
fi

clone_gh_repo_and_pull_latest() {
	local gh_repo_clone_url="$1"
	local gh_repo_target_folder_name="$2"
	local branch="${3:-main}"
	local pull_latest="${4:-1}"

	local full_path="${ML_HOMELAB_ROOT}/${gh_repo_target_folder_name}"

	if [[ -e "$full_path" ]]; then
		echo "Repo already exists at $full_path"
	else
		echo "Cloning repo into $full_path"
		git clone "$gh_repo_clone_url" "$full_path"
	fi

	echo "Changing working directory to $full_path"
	cd "$full_path" || {
		echo "Failed to cd into $full_path"
		return 1
	}

	echo "Fetching latest info from remote"
	git fetch origin

	echo "Checking out branch $branch"
	git checkout "$branch" || {
		echo "Failed to checkout branch $branch"
		return 1
	}

	if [[ "$pull_latest" == "1" ]]; then
		echo "Pulling latest changes from remote"
		git pull origin "$branch"
	else
		echo "Not pulling latest from remote; using local state"
	fi
}
