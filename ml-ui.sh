#!/bin/bash
set -e

cd "${ML_WORKSPACE_ROOT}/ml-ui" || {
	echo "Failed to cd into ml-ui repo."
	exit 1
}

docker-compose -f docker-compose.dummy_project.yaml up --build
