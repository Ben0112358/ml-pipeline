#!/bin/bash
set -euo pipefail

source ./utils.sh
PROJECT_NAME="$1"
MODE="$2"
OUTPUT_SUFFIX="$3"
log "INFO" "Running $0 with args: $1, $2."

log "INFO" "Running setup."
./setup.sh "$MODE"

log "INFO" "Setup succeeded => rename log file from unknown to the known project name."
NEW_LOG_FILE_PATH="${ML_HOMELAB_ROOT}/log_ml-pipeline_${OUTPUT_SUFFIX}.log"
mv "${LOG_FILE_PATH}" "${NEW_LOG_FILE_PATH}"
LOG_FILE_PATH=$NEW_LOG_FILE_PATH

log "INFO" "Running ml-infra."
./ml-infra.sh "$PROJECT_NAME" "$MODE"
mv "${ML_HOMELAB_ROOT}/log_${OUTPUT_SUFFIX}.log" "${ML_HOMELAB_ROOT}/logs/infra/log_${OUTPUT_SUFFIX}.log"

log "INFO" "Running ml-data."
./ml-data.sh "$PROJECT_NAME"

log "INFO" "Running ml-training."
./ml-training.sh "$PROJECT_NAME"

log "INFO" "Running serving."
./ml-serving.sh "$PROJECT_NAME"

log "INFO" "Running ml-ui."
./ml-ui.sh "$PROJECT_NAME"

mv "${LOG_FILE_PATH}" "${ML_HOMELAB_ROOT}/logs/pipeline/log_${OUTPUT_SUFFIX}.log"
