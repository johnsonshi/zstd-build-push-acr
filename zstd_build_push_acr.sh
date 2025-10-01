#!/usr/bin/env bash
set -euo pipefail

# ---- Args ----
if [ $# -lt 1 ]; then
  echo "Usage: $0 <registry-name>"
  exit 1
fi

# ---- Variables ----
REGISTRY="$1"
LOGIN_SERVER="${REGISTRY}.azurecr.io"
IMAGE="${LOGIN_SERVER}/demo/alpine:zstd"

echo "==> Logging into Azure Container Registry: $REGISTRY"
az acr login --name "$REGISTRY"

# ---- Set up buildx context ----
echo "==> Removing existing builder if any"
docker buildx rm -f zstdbuilder || true # Remove if exists
echo "==> Creating and bootstrapping temporary builder"
docker buildx create --name zstdbuilder --use \
    --driver docker-container \
    --driver-opt image=moby/buildkit:latest
docker buildx inspect --bootstrap

# ---- Build and push image with zstd-compressed layers ----
echo "==> Building and pushing image: $IMAGE"
docker buildx build \
    --file Dockerfile \
    --build-arg BUILD_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --output "type=image,name=${IMAGE},oci-mediatypes=true,compression=zstd,compression-level=3,force-compression=true,push=true" \
    --provenance=false \
    .

# ---- Cleanup local artifacts (image and buildx context) ----
echo "==> Cleaning up local Docker image and buildx context"
docker rmi "$IMAGE" || true
docker buildx prune -af
docker buildx rm zstdbuilder

# ---- Use oras to fetch image manifest to confirm layers are zstd-compressed ----
echo "==> Using oras to fetch image manifest for $IMAGE"
oras manifest fetch --pretty "$IMAGE"

# ---- Use docker to fetch image manifest to confirm layers are zstd-compressed ----
echo "==> Using docker to fetch image manifest for $IMAGE"
docker manifest inspect -v "$IMAGE"

# ---- Pull and inspect image with docker ----
echo "==> Using docker to pull the image with zstd-compressed layers"
docker pull "$IMAGE"

# ---- Cleanup local Docker image ----
echo "==> Cleaning up local Docker image"
docker rmi "$IMAGE" || true

echo "==> Done!"
