#!/bin/bash
set -euo pipefail

log() {
	local severity="$1"
	local msg="$2"

	case "$severity" in
	INFO | WARNING | ERROR) ;;
	*)
		echo "Invalid log level: $severity"
		return 1
		;;
	esac

	local full_row="$(date -u +"%a %b %d %T UTC %Y") - $severity: $msg"
	echo "$full_row"
	echo "$full_row" >>"${PIPELINE_LOG_FILE_PATH}"
}

log_safe() {
	set +e
	log "$1" "$2"
	set -e
}

cleanup() {
	local status=$?

	if [ "$status" -ne 0 ]; then
		log_safe "ERROR" "Pipeline failed (${status})"
		log_safe "ERROR" "Last command: ${BASH_COMMAND:-unknown}"
	else
		log_safe "INFO" "Pipeline finished successfully (0)"
	fi
}

cd_stage_repo() {
	local repo_folder_name="$1"

	cd "${ML_WORKSPACE_ROOT}/${repo_folder_name}" || {
		log "ERROR" "Failed to cd into ${repo_folder_name} repo."
		exit 1
	}
}

compose_stage_repo() {
	local repo_folder_name="$1"
	local project_name="$2"

	cd_stage_repo "$repo_folder_name"

	log "INFO" "Docker composing."
	local compose_args=(-f "docker-compose.${project_name}.yaml" -p "${project_name}_${MODE}")
	docker-compose "${compose_args[@]}" build --no-cache
	docker-compose "${compose_args[@]}" up -d
}

run_stage() {
	local repo_folder_name="$1"
	local project_name="${2:-}"

	log "INFO" "$0 executed for project $project_name"

	if [[ -z "$project_name" ]]; then
		log "ERROR" "Usage: $0 <project_name>"
		exit 1
	fi

	compose_stage_repo "$repo_folder_name" "$project_name"
}
