#!/usr/bin/env bash

# Bundle OpenAPI specification using Vacuum

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths

print_step "Bundling OpenAPI specification using Vacuum"

require_file "${SPEC_FILE}"
ensure_dir "${GEN_DIR}"

run "Running vacuum bundle" \
  npx vacuum bundle "${SPEC_FILE}" "${BUNDLE_FILE}" --base "${SPEC_DIR}"

echo ""
echo "Bundling completed"
echo "  Output: ${BUNDLE_FILE}"
echo ""
echo "Warning"
echo "  Vacuum does not render securitySchemes correctly"
echo "  Use only if Vacuum version is newer than 0.23.0"
echo ""