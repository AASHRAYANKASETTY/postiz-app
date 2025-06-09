#!/bin/bash

set -o xtrace

# Clean up existing image
docker rmi localhost/postiz || true

# Build with explicit platform targeting AMD64
docker build --platform linux/amd64 --target dist -t localhost/postiz -f Dockerfile.dev .
docker build --platform linux/amd64 --target devcontainer -t localhost/postiz-devcontainer -f Dockerfile.dev .

