#!/bin/bash

set -o xtrace

# Target platform for the image. Set PLATFORM to linux/arm64 when your cluster
# uses ARM64 nodes. A comma separated list (e.g. linux/amd64,linux/arm64) can be
# used to build a multi-architecture image.
PLATFORM="${PLATFORM:-linux/amd64}"

# Ensure buildx is initialized
docker buildx inspect >/dev/null 2>&1 || docker buildx create --use

docker rmi localhost/postiz || true
docker buildx build --platform "$PLATFORM" --target dist -t localhost/postiz -f Dockerfile.dev .
docker buildx build --platform "$PLATFORM" --target devcontainer -t localhost/postiz-devcontainer -f Dockerfile.dev .
