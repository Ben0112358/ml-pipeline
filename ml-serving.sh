#!/bin/bash
set -euo pipefail

source ./utils.sh
PROJECT_NAME="${1:-}"
log "INFO" "$0 executed for project $PROJECT_NAME"

if [[ -z "$PROJECT_NAME" ]]; then
	log "ERROR" "Usage: $0 <project_name>"
	exit 1
fi

compose_stage_repo "ml-serving" "$PROJECT_NAME"
