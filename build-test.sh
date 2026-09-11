#!/bin/bash

set -euo pipefail

docker buildx create --name nilcons-debian-zstd-builder --driver docker-container
trap 'docker buildx rm nilcons-debian-zstd-builder' EXIT
docker buildx build --builder nilcons-debian-zstd-builder --provenance=false --output type=image,name=ttl.sh/nilcons/debian:2h,compression=zstd,force-compression=true,oci-mediatypes=true,push=true .
