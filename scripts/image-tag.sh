#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG_STRATEGY="${IMAGE_TAG_STRATEGY:-git-sha}"

if [[ "${IMAGE_TAG_STRATEGY}" == "git-sha" ]]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git rev-parse --short HEAD
  else
    date +%Y%m%d%H%M%S
  fi
elif [[ "${IMAGE_TAG_STRATEGY}" == "timestamp" ]]; then
  date +%Y%m%d%H%M%S
else
  echo "Unsupported IMAGE_TAG_STRATEGY: ${IMAGE_TAG_STRATEGY}" >&2
  exit 1
fi
