#!/bin/bash
set -euo pipefail


log() {
	local severity="$1"
	local msg="$2"


	case "$severity" in
		INFO|WARNING|ERROR)
			;;
		*)
			echo "Invalid log level: $severity"
			return 1
			;;
	esac

	local full_row="$(date -u +"%a %b %d %T UTC %Y") - $severity: $msg"
	echo "$full_row"
	echo "$full_row" >> "${PIPELINE_LOG_FILE_PATH}"
}

log_safe() {
	set +e
	log "$1" "$2"
	set -e
}


cleanup() {
	local status=$?

	if [ "$status" -ne 0 ]; then
		log_safe "ERROR" "Pipeline failed (${status})"
		log_safe "ERROR" "Last command: ${BASH_COMMAND:-unknown}"
	else
		log_safe "INFO" "Pipeline finished successfully (0)"
	fi
}


