#!/bin/bash

source ./utils.sh

PREFIX="${1:-}"

log "INFO" "Running $0 with args: $1."

{ docker ps -a --format "{{.ID}} {{.Names}}" |
    grep "^.* ${PREFIX}" |
    awk '{print $1}' |
    xargs -r docker rm -f; } || log "INFO" "No containers to clean up."


{ docker images --format "{{.ID}} {{.Repository}}:{{.Tag}}" |
    grep "${PREFIX}" |
    awk '{print $1}' |
    xargs -r docker rmi -f; } || log "INFO" "No images to clean up."


{ docker volume ls --format "{{.Name}}" |
    grep "${PREFIX}" |
    xargs -r docker volume rm; } || log "INFO" "No volumes to clean up."

{ docker network ls --format "{{.ID}} {{.Name}}" |
    grep "${PREFIX}" |
    awk '{print $1}' |
    xargs -r docker network rm; } || log "INFO" "No networks to clean up."

log "INFO" "Prune cache."
docker builder prune -f 

log "INFO" "Remove dangling images"
docker image prune -f