#!/bin/bash
set -euo pipefail

source ./utils.sh
trap cleanup EXIT

if [[ -z "$ML_HOMELAB_ROOT" ]]; then
	echo "Error: MY_VAR is not set. Exiting."
	exit 1
fi

mkdir -p $ML_HOMELAB_ROOT

rm -f ${ML_HOMELAB_ROOT}/*.log

export PIPELINE_LOG_FILE_PATH="${ML_HOMELAB_ROOT}/unknown-pipeline.log"
log "INFO" "Execution of pipeline started."
log "INFO" "Env var ML_HOMELAB_ROOT exists and a directory has been created (if it didn't already exist)."

if [[ $# -ne 2 ]]; then
	log "ERROR" "$0 expected 2 arguments, got $#. Usage: $0 <project_name> <mode: prod|dev>"
	exit 1
fi

PROJECT="$1"
MODE="$2"

log "INFO" "$0 was called with args (in order): $1, $2."

if [[ "$MODE" != "prod" && "$MODE" != "dev" ]]; then
	log "ERROR" "Mode must be 'prod' or 'dev', but got '$MODE'"
	exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
OUTPUT_SUFFIX="${PROJECT}_${MODE}_${TIMESTAMP}"
IMAGE_NAME="${PROJECT}-pipeline-image-${MODE}"
KILL_PREFIX="${PROJECT}_${MODE}"

log "INFO" "Clean up existing docker stuff for ${KILL_PREFIX}."
source ./cleanup-docker-prefix.sh "$KILL_PREFIX"

log "INFO" "Building docker image $IMAGE_NAME."
docker build -t "$IMAGE_NAME" . --no-cache

log "INFO" "Compute ports to be used by serving and ui"
HASH=$(echo -n "${PROJECT}_${MODE}" | md5sum | cut -c1-6)
BASE_PORT=$((0x$HASH % 32000 + 8000))

SERVING_PORT=$BASE_PORT
UI_PORT=$((BASE_PORT + 1))
log "INFO" "Serving port: ${SERVING_PORT}; UI port: ${UI_PORT}"

docker_cmd="docker run --rm \
  -v ~/.netrc:/root/.netrc:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v \"$ML_HOMELAB_ROOT\":\"$ML_HOMELAB_ROOT\":rw \
  -e ML_HOMELAB_ROOT=\"$ML_HOMELAB_ROOT\" \
  -e TF_VAR_ml_homelab_root=\"$ML_HOMELAB_ROOT\" \
  -e ML_WORKSPACE_ROOT=/ml_workspace_root \
  -e MODE=\"$MODE\" \
  -e TF_VAR_mode=\"$MODE\" \
  -e PROJECT_NAME=\"$PROJECT\" \
  -e TF_VAR_project_name=\"$PROJECT\" \
  -e DOCKER_NETWORK_NAME=\"${PROJECT}_${MODE}\" \
  -e TF_VAR_docker_network_name=\"${PROJECT}_${MODE}\" \
  -e PIPELINE_LOG_FILE_PATH=\"$PIPELINE_LOG_FILE_PATH\" \
  -e TIMESTAMP=\"$TIMESTAMP\" \
  -e TF_VAR_timestamp=\"$TIMESTAMP\" \
  -e OUTPUT_SUFFIX=\"$OUTPUT_SUFFIX\" \
  -e TF_VAR_output_suffix=\"$OUTPUT_SUFFIX\" \
  -e SERVING_PORT=\"$SERVING_PORT\" \
  -e UI_PORT=\"$UI_PORT\" \
  -e TF_LOG=INFO \
  -e TF_LOG_PATH=\"${ML_HOMELAB_ROOT}/log_${OUTPUT_SUFFIX}.log\" \
  \"$IMAGE_NAME\" \"$PROJECT\" \"$MODE\" \"$OUTPUT_SUFFIX\""

log "INFO" "Running: $docker_cmd"
eval "$docker_cmd"
echo "Serving: http://localhost:${SERVING_PORT}; UI: http://localhost:${UI_PORT}"