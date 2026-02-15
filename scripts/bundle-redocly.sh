#!/usr/bin/env bash

# Bundle OpenAPI specification using Redocly

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SPEC_FILE="${SPEC_FILE:-./spec/openapi.yaml}"
GEN_DIR="${GEN_DIR:-./gen}"
BUNDLE_FILE="${BUNDLE_FILE:-./gen/openapi.yaml}"

print_step "Bundling OpenAPI specification using Redocly"

require_file "${SPEC_FILE}"
ensure_dir "${GEN_DIR}"

run "Running redocly bundle" \
  npx redocly bundle "${SPEC_FILE}" -o "${BUNDLE_FILE}"

echo ""
echo "Bundling completed"
echo "  Output: ${BUNDLE_FILE}"
echo ""
