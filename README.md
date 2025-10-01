# Azure Container Registry Zstd Compression Demo

This repo shows that **Azure Container Registry (ACR)** supports pushing and pulling images with **zstd-compressed layers**.

It contains a simple Dockerfile that builds an image with a random build-stamp layer.
A script then uses Docker Buildx to build the image with zstd compression for the image layers and pushes it to ACR.

The script then verifies the image is pullable from ACR by first clearing the local Docker cache before pulling the image again.

The script uses both `oras` and `docker` commands to fetch and inspect the image manifest, confirming that the layers are indeed zstd-compressed.

## Files

- `README.md` - this file.
- `Dockerfile` - builds a simple base image with an additional layer containing the build timestamp.
- `zstd_build_push_acr.sh` - script to build, push, and verify zstd layers.

## Requirements

- An Azure Container Registry (ACR) instance (any SKU).
- Docker (`docker`) installed with Buildx support.
- `oras` CLI installed (for inspecting image manifests). You can install it by following [oras docs](https://oras.land/docs/installation).

## Usage

```bash
./zstd_build_push_acr.sh "<acr-registry-name-without-azurecr.io>"
```
