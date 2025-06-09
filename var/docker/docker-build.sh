#!/bin/bash
set -o xtrace

# Target platform(s) for the image. Defaults to linux/amd64. Set PLATFORM to
# linux/arm64 when your cluster uses ARM64 nodes, or provide a comma separated
# list such as "linux/amd64,linux/arm64" to build a multi-architecture image
# that runs on both AKS and macOS.
# How to publish the image. Set OUTPUT=push to push to your registry. The
# default OUTPUT=load loads the result into the local Docker daemon.
OUTPUT="${OUTPUT:-load}"
if [ "$OUTPUT" = "push" ]; then
  OUT_FLAG="--push"
else
  OUT_FLAG="--load"
fi

docker buildx build $OUT_FLAG --platform "$PLATFORM" \
docker buildx build $OUT_FLAG --platform "$PLATFORM" \
  -t localhost/postiz \
  -f Dockerfile.dev .

docker buildx build \
  --platform linux/amd64 \
  --target devcontainer \
  -t localhost/postiz-devcontainer \
  -f Dockerfile.dev .
