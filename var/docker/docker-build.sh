#!/bin/bash

set -o xtrace

# Target platform for the image. Defaults to linux/amd64 which works on most AKS nodes.
PLATFORM="${PLATFORM:-linux/amd64}"

# Ensure buildx is initialized
docker buildx inspect >/dev/null 2>&1 || docker buildx create --use

docker rmi localhost/postiz || true
docker buildx build --platform "$PLATFORM" --target dist -t localhost/postiz -f Dockerfile.dev .
docker buildx build --platform "$PLATFORM" --target devcontainer -t localhost/postiz-devcontainer -f Dockerfile.dev .
