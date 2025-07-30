#!/bin/bash
set -euo

PROJECT_NAME="$1"
MODE="$2"

echo "---Running setup---"
./setup.sh "$MODE"

echo "---Running infra---"
./ml-infra.sh "$PROJECT_NAME" "$MODE"

echo "---Running data---"
./ml-data.sh "$PROJECT_NAME"

echo "---Running training---"
./ml-training.sh "$PROJECT_NAME"

echo "---Running serving---"
./ml-serving.sh "$PROJECT_NAME"

echo "---Running ui---"
./ml-ui.sh "$PROJECT_NAME"
