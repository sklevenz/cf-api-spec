#!/usr/bin/env bash

set -euo pipefail

# Bundle the OpenAPI specification using Vacuum.
# Requirements: node, npx
# Output: ${BUNDLE_FILE}

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

init_common_paths

if ! command -v npx >/dev/null 2>&1; then
  fail "npx is required to run vacuum bundle"
fi

main() {
  print_step "Bundling OpenAPI specification using Vacuum"

  require_file "${SPEC_FILE}"
  ensure_dir "${GEN_DIR}"

  run "Running vacuum bundle" \
    npx --yes vacuum bundle "${SPEC_FILE}" "${BUNDLE_FILE}" --base "${SPEC_DIR}"

  echo ""
  echo "Bundling completed"
  echo "  Output: ${BUNDLE_FILE}"
  echo ""
  echo "Warning"
  echo "  Vacuum may not render securitySchemes correctly"
  echo "  Use only if Vacuum version is newer than 0.23.0"
  echo ""
}

main "$@"