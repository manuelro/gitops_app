#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

IMAGE_REGISTRY="${IMAGE_REGISTRY:-localhost:5001}"
CLIENT_IMAGE_NAME="${CLIENT_IMAGE_NAME:-demo-client}"
API_IMAGE_NAME="${API_IMAGE_NAME:-demo-api}"

TAG="$(${SCRIPT_DIR}/image-tag.sh)"
CLIENT_REF="${IMAGE_REGISTRY}/${CLIENT_IMAGE_NAME}:${TAG}"
API_REF="${IMAGE_REGISTRY}/${API_IMAGE_NAME}:${TAG}"

echo "[app] Building ${CLIENT_REF}"
docker build -t "${CLIENT_REF}" "${REPO_DIR}/client"

echo "[app] Building ${API_REF}"
docker build -t "${API_REF}" "${REPO_DIR}/api"

echo "[app] Pushing ${CLIENT_REF}"
docker push "${CLIENT_REF}"

echo "[app] Pushing ${API_REF}"
docker push "${API_REF}"

echo "[app] Build and push complete"
echo "[app] CLIENT_IMAGE=${CLIENT_REF}"
echo "[app] API_IMAGE=${API_REF}"
echo "[app] IMAGE_TAG=${TAG}"

if [[ "${AUTO_PROMOTE_INFRA:-false}" == "true" ]]; then
  echo "[app] AUTO_PROMOTE_INFRA=true, promoting tag ${TAG} to infra repo"
  "${SCRIPT_DIR}/promote-to-infra.sh" "${TAG}"
fi
