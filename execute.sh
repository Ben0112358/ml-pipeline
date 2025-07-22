#!/bin/bash
set -euo

IMAGE_NAME="my-ml-pipeline-image"

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" . --no-cache

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$ML_HOMELAB_ROOT":"$ML_HOMELAB_ROOT":rw \
  -e ML_HOMELAB_ROOT="$ML_HOMELAB_ROOT" \
  -e TF_VAR_ml_homelab_root="$ML_HOMELAB_ROOT" \
  -e ML_WORKSPACE_ROOT=/ml_workspace_root \
  "$IMAGE_NAME" \
  ./pipeline.sh "$@"
