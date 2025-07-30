#!/bin/bash
set -euo pipefail

PROJECT_NAME="${1:-}"

if [[ -z "$PROJECT_NAME" ]]; then
	echo "Usage: $0 <project_name>"
	exit 1
fi

cd "${ML_WORKSPACE_ROOT}/ml-ui" || {
	echo "Failed to cd into ml-ui repo."
	exit 1
}

docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" -p "${PROJECT_NAME}_${MODE}" build --no-cache
docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" -p "${PROJECT_NAME}_${MODE}" up -d

