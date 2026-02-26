#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

TAG="${1:-}"
if [[ -z "${TAG}" ]]; then
  TAG="$("${SCRIPT_DIR}/image-tag.sh")"
fi

INFRA_REPO_DIR="${INFRA_REPO_DIR:-${APP_REPO_DIR}/../infra}"
INFRA_REPO_URL="${INFRA_REPO_URL:-}"
INFRA_BRANCH="${INFRA_BRANCH:-main}"
INFRA_OVERLAY="${INFRA_OVERLAY:-local}"
INFRA_FILE_REL="apps/demo/overlays/${INFRA_OVERLAY}/kustomization.yaml"
INFRA_FILE=""

ensure_repo() {
  if [[ -d "${INFRA_REPO_DIR}/.git" ]]; then
    return
  fi

  if [[ -z "${INFRA_REPO_URL}" ]]; then
    echo "Missing infra repo: set INFRA_REPO_DIR to an existing repo or set INFRA_REPO_URL to clone." >&2
    exit 1
  fi

  echo "[app] Cloning infra repo ${INFRA_REPO_URL} into ${INFRA_REPO_DIR}"
  git clone "${INFRA_REPO_URL}" "${INFRA_REPO_DIR}"
}

update_tags() {
  local file="$1"
  local tag="$2"

  awk -v tag="${tag}" '
    BEGIN { in_client=0; in_api=0 }
    /^[[:space:]]*-[[:space:]]+name:[[:space:]]*demo-client[[:space:]]*$/ { in_client=1; in_api=0; print; next }
    /^[[:space:]]*-[[:space:]]+name:[[:space:]]*demo-api[[:space:]]*$/ { in_api=1; in_client=0; print; next }
    /^[[:space:]]*-[[:space:]]+name:[[:space:]]*/ { in_client=0; in_api=0; print; next }
    (in_client || in_api) && /^[[:space:]]*newTag:[[:space:]]*/ {
      sub(/newTag:.*/, "newTag: \"" tag "\"")
      print
      next
    }
    { print }
  ' "${file}" > "${file}.tmp"
  mv "${file}.tmp" "${file}"
}

ensure_repo

if [[ ! -d "${INFRA_REPO_DIR}/.git" ]]; then
  echo "Not a git repository: ${INFRA_REPO_DIR}" >&2
  exit 1
fi

git -C "${INFRA_REPO_DIR}" fetch origin "${INFRA_BRANCH}" >/dev/null 2>&1 || true
if git -C "${INFRA_REPO_DIR}" show-ref --verify --quiet "refs/heads/${INFRA_BRANCH}"; then
  git -C "${INFRA_REPO_DIR}" checkout "${INFRA_BRANCH}" >/dev/null
else
  git -C "${INFRA_REPO_DIR}" checkout -b "${INFRA_BRANCH}" >/dev/null
fi
git -C "${INFRA_REPO_DIR}" pull --ff-only origin "${INFRA_BRANCH}" >/dev/null 2>&1 || true

INFRA_FILE="${INFRA_REPO_DIR}/${INFRA_FILE_REL}"
if [[ ! -f "${INFRA_FILE}" ]]; then
  echo "Infra file not found: ${INFRA_FILE}" >&2
  exit 1
fi

echo "[app] Updating infra image tags in ${INFRA_FILE_REL} to ${TAG}"
update_tags "${INFRA_FILE}" "${TAG}"

git -C "${INFRA_REPO_DIR}" add "${INFRA_FILE_REL}"
if git -C "${INFRA_REPO_DIR}" diff --cached --quiet; then
  echo "[app] No infra changes to commit"
  exit 0
fi

GIT_AUTHOR_NAME="${GIT_AUTHOR_NAME:-App Auto Promote}"
GIT_AUTHOR_EMAIL="${GIT_AUTHOR_EMAIL:-app-autopromote@example.local}"
GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-${GIT_AUTHOR_NAME}}"
GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-${GIT_AUTHOR_EMAIL}}"

git -C "${INFRA_REPO_DIR}" \
  -c user.name="${GIT_AUTHOR_NAME}" \
  -c user.email="${GIT_AUTHOR_EMAIL}" \
  commit -m "chore(demo): bump demo images to ${TAG}" >/dev/null

echo "[app] Pushing infra commit to ${INFRA_BRANCH}"
git -C "${INFRA_REPO_DIR}" push origin "${INFRA_BRANCH}"
echo "[app] Infra promotion complete"
