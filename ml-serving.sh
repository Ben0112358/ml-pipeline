#!/bin/bash
set -euo pipefail

source ./utils.sh
run_stage "ml-serving" "${1:-}"
