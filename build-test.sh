#!/bin/bash

set -euo pipefail

docker build -t ttl.sh/nilcons/debian:2h .
docker push ttl.sh/nilcons/debian:2h
