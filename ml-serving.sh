#!/bin/bash
set -euo pipefail

PROJECT_NAME="${1:-}"

if [[ -z "$PROJECT_NAME" ]]; then
	echo "Usage: $0 <project_name>"
	exit 1
fi

cd "${ML_WORKSPACE_ROOT}/ml-serving" || {
	echo "Failed to cd into ml-serving repo."
	exit 1
}

docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" build --no-cache
docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" up -d
