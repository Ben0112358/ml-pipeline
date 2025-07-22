#!/bin/bash
set -euo

echo "---Running setup---"
./setup.sh

echo "---Running infra---"
./ml-infra.sh "$1"

echo "---Running data---"
./ml-data.sh "$1"

echo "---Running training---"
./ml-training.sh "$1"

echo "---Running serving---"
./ml-serving.sh "$1"

echo "---Running ui---"
./ml-ui.sh "$1"
