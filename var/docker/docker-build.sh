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

# Optional image names. Override these to push somewhere other than localhost.
IMAGE="${IMAGE:-localhost/postiz}"
DEVIMAGE="${DEVIMAGE:-localhost/postiz-devcontainer}"

docker rmi "$IMAGE" || true
docker buildx build $OUT_FLAG --platform "$PLATFORM" \
  --target dist -t "$IMAGE" -f Dockerfile.dev .
  --target devcontainer -t "$DEVIMAGE" -f Dockerfile.dev .

docker buildx build \
  --platform linux/amd64 \
  --target devcontainer \
  -t localhost/postiz-devcontainer \
  -f Dockerfile.dev .
