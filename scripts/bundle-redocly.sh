#!/usr/bin/env bash

set -euo pipefail

# Bundle the OpenAPI specification using Redocly.
# Requirements: node, npx
# Output: ${BUNDLE_FILE}

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"
init_common_paths

if ! command -v npx >/dev/null 2>&1; then
  fail "npx is required to run redocly bundle"
fi

main() {
  print_step "Bundling OpenAPI specification using Redocly"

  require_file "${SPEC_FILE}"
  ensure_dir "${GEN_DIR}"

  run "Running redocly bundle" \
    npx --yes @redocly/cli bundle "${SPEC_FILE}" -o "${BUNDLE_FILE}"

  echo ""
  echo "Bundling completed"
  echo "  Output: ${BUNDLE_FILE}"
  echo ""
}

main "$@"
