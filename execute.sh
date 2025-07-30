#!/bin/bash
set -euo

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <project_name> <mode: prod|dev>"
	exit 1
fi

PROJECT="$1"
MODE="$2"

if [[ "$MODE" != "prod" && "$MODE" != "dev" ]]; then
	echo "Error: Mode must be 'prod' or 'dev', but got '$MODE'"
	exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
OUTPUT_SUFFIX="${PROJECT}_${MODE}_${TIMESTAMP}"
IMAGE_NAME="${PROJECT}-pipeline-image-${MODE}"

docker ps --format "{{.ID}} {{.Image}}" |
	grep "${PROJECT}_${MODE}_" |
	awk '{print $1}' |
	xargs -r docker kill

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" . --no-cache

HASH=$(echo -n "${PROJECT}_${MODE}" | md5sum | cut -c1-6)
BASE_PORT=$((0x$HASH % 32000 + 8000))

SERVING_PORT=$BASE_PORT
UI_PORT=$((BASE_PORT + 1))

docker run --rm \
	-v ~/.netrc:/root/.netrc:ro \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "$ML_HOMELAB_ROOT":"$ML_HOMELAB_ROOT":rw \
	-e ML_HOMELAB_ROOT="$ML_HOMELAB_ROOT" \
	-e TF_VAR_ml_homelab_root="$ML_HOMELAB_ROOT" \
	-e ML_WORKSPACE_ROOT=/ml_workspace_root \
	-e MODE="$MODE" \
	-e TF_VAR_mode="$MODE" \
	-e PROJECT_NAME="$PROJECT" \
	-e TF_VAR_project_name="$PROJECT" \
	-e DOCKER_NETWORK_NAME="${PROJECT}_${MODE}" \
	-e TF_VAR_docker_network_name="${PROJECT}_${MODE}" \
	-e TIMESTAMP="$TIMESTAMP" \
	-e TF_VAR_timestamp="$TIMESTAMP" \
	-e OUTPUT_SUFFIX="$OUTPUT_SUFFIX" \
	-e TF_VAR_output_suffix="$OUTPUT_SUFFIX" \
	-e SERVING_PORT="$SERVING_PORT" \
	-e UI_PORT="$UI_PORT" \
	"$IMAGE_NAME" "$PROJECT" "$MODE"
