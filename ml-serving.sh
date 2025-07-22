#!/bin/bash
set -e

cd "${ML_WORKSPACE_ROOT}/ml-serving" || {
  echo "Failed to cd into ml-serving repo."
  exit 1
}

docker-compose -f docker-compose.dummy_project.yaml up --build -d