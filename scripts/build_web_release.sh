#!/usr/bin/env bash
# Build web release with Sentry source map upload.
#
# Prerequisites:
#   export SENTRY_AUTH_TOKEN="sntrys_..."   # org token, never commit
#
# Usage:
#   ./scripts/build_web_release.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -z "${SENTRY_AUTH_TOKEN:-}" ]]; then
  echo "Error: SENTRY_AUTH_TOKEN is not set."
  echo "Create an org token at sentry.io → Settings → Developer Settings → Organization Tokens"
  exit 1
fi

export SENTRY_ORG="${SENTRY_ORG:-super-io-limited}"
export SENTRY_PROJECT="${SENTRY_PROJECT:-flutter}"
export SENTRY_URL="${SENTRY_URL:-https://de.sentry.io}"

fvm flutter build web --release --source-maps

echo "Web release build complete. Source maps uploaded when SENTRY_AUTH_TOKEN is valid."
