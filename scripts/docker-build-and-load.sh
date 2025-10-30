#!/usr/bin/env bash
set -euo pipefail

# Usage: docker-build-and-load.sh <image-name>
# Relies on BUILD_NUMBER and USE_MINIKUBE_DOCKER env vars from the pipeline.

IMAGE_NAME="$1"
BUILD_NUMBER_VALUE="${BUILD_NUMBER:-local}"
TAG_LATEST="${IMAGE_NAME}:latest"
TAG_NUMBER="${IMAGE_NAME}:${BUILD_NUMBER_VALUE}"

echo "📦 Building image: ${IMAGE_NAME} (tag: ${TAG_NUMBER})"

build_locally() {
  echo "🔨 Building locally: ${TAG_LATEST}"
  docker build -t "${TAG_LATEST}" .
  docker tag "${TAG_LATEST}" "${TAG_NUMBER}"
}

try_minikube_image_load() {
  # Prefer `minikube image load` which is more reliable than docker save/load
  if minikube status -p minikube >/dev/null 2>&1; then
    echo "🔁 Attempting to load ${TAG_LATEST} into Minikube with 'minikube image load'"
    if minikube image load "${TAG_LATEST}" -p minikube >/dev/null 2>&1; then
      echo "✅ Loaded ${TAG_LATEST} into Minikube"
      return 0
    else
      echo "⚠️ 'minikube image load' failed; falling back to docker save | docker exec -i minikube docker load"
      if docker save "${TAG_LATEST}" | docker exec -i minikube docker load >/dev/null 2>&1; then
        echo "✅ Loaded ${TAG_LATEST} into Minikube via save|load"
        return 0
      else
        echo "❌ Failed to load image into Minikube"
        return 1
      fi
    fi
  else
    echo "⚠️ Minikube not running; cannot load image into Minikube"
    return 1
  fi
}

if [ "${USE_MINIKUBE_DOCKER:-false}" = "true" ]; then
  echo "⚠️ USE_MINIKUBE_DOCKER=true — attempting to build inside Minikube's Docker daemon"

  if minikube status -p minikube >/dev/null 2>&1; then
    # Check whether we can get docker-env for minikube; if this fails, it's likely a permission/socket issue
    if minikube -p minikube docker-env --shell bash >/dev/null 2>&1; then
      echo "🔧 Configuring shell to use Minikube's Docker daemon"
      # shellcheck disable=SC1091
      eval "$(minikube -p minikube docker-env --shell bash)"
      echo "🔨 Building inside Minikube's Docker daemon"
      docker build -t "${TAG_LATEST}" .
      docker tag "${TAG_LATEST}" "${TAG_NUMBER}"
      echo "✅ Built ${TAG_LATEST} inside Minikube daemon"
      exit 0
    else
      echo "⚠️ Unable to configure Minikube docker env (permission/socket). Falling back to local build + load"
      build_locally
      try_minikube_image_load || echo "ℹ️ Built image is available locally as ${TAG_NUMBER}"
      exit 0
    fi
  else
    echo "⚠️ Minikube not running. Building locally and leaving image in local Docker daemon"
    build_locally
    try_minikube_image_load || echo "ℹ️ Built image is available locally as ${TAG_NUMBER}"
    exit 0
  fi
else
  # Default: build locally and attempt to load into minikube if available
  build_locally
  try_minikube_image_load || echo "ℹ️ Built image is available locally as ${TAG_NUMBER}"
  exit 0
fi
