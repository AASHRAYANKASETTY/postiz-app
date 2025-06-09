#!/bin/bash
set -o xtrace

docker rmi localhost/postiz || true

docker buildx build \
  --platform linux/amd64 \
  --target dist \
  -t localhost/postiz \
  -f Dockerfile.dev .

docker buildx build \
  --platform linux/amd64 \
  --target devcontainer \
  -t localhost/postiz-devcontainer \
  -f Dockerfile.dev .
