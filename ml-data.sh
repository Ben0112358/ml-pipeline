#!/bin/bash
set -euo pipefail

echo "DEBUG \$0: $0"
echo "DEBUG \$@: $@"

PROJECT_NAME="${1:-}"

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

cd "${ML_WORKSPACE_ROOT}/ml-data" || {
  echo "Failed to cd into ml-data repo."
  exit 1
}

docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" build --no-cache
docker-compose -f "docker-compose.${PROJECT_NAME}.yaml" up -d

