#!/bin/bash
set -euo pipefail

LOG_FILE_PATH="${ML_HOMELAB_ROOT}/unknown-pipeline.log"

log() {
	local severity="$1"
	local msg="$2"

	local full_row="$(date -u +"%a %b %d %T UTC %Y") - $severity: $msg"
	echo "$msg"
	echo "$full_row" >>"${LOG_FILE_PATH}"
}
