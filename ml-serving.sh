#!/bin/bash
set -euo pipefail

source ./utils.sh
PROJECT_NAME="${1:-}"
log "INFO" "$0 executed for project $PROJECT_NAME"

if [[ -z "$PROJECT_NAME" ]]; then
	log "ERROR" "Usage: $0 <project_name>"
	exit 1
fi

cd "${ML_WORKSPACE_ROOT}/ml-serving" || {
	log "ERROR" "Failed to cd into ml-serving repo."
	exit 1
}

log "INFO" "Docker composing."
docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" -p "${PROJECT_NAME}_${MODE}" build --no-cache
docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" -p "${PROJECT_NAME}_${MODE}" up -d
