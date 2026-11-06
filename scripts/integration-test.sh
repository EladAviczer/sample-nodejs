#!/usr/bin/env bash
# Runs the built image like Kubernetes does (read-only, non-root) and checks every endpoint responds.
# Usage: scripts/integration-test.sh <image>
set -euo pipefail

IMAGE="$1"

docker run -d --name sample-app-it --read-only --user 1000 -p 8080:8080 "$IMAGE"

# Set only after our container started, so a failed start never removes another container
trap 'docker rm -f sample-app-it > /dev/null' EXIT

# Wait up to 30s for the app to become ready
for i in $(seq 1 30); do
    curl -fs http://localhost:8080/ready > /dev/null && break
    if [ "$i" = 30 ]; then
        echo "App did not become ready"
        docker logs sample-app-it
        exit 1
    fi
    sleep 1
done

for path in /live /ready /my-app /about /metrics /classified; do
    echo "GET $path"
    curl -fsS -o /dev/null "http://localhost:8080$path" || { docker logs sample-app-it; exit 1; }
done
