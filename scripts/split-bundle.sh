#!/usr/bin/env bash

# Split bundled OpenAPI spec back into file structure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths
set_default SPLIT_DIR "${GEN_DIR}/spec"

print_step "Splitting bundled OpenAPI specification"

require_file "${BUNDLE_FILE}"

run "Removing previous split output" rm -rf "${SPLIT_DIR}"
run "Running redocly split" npx redocly split "${BUNDLE_FILE}" --outDir "${SPLIT_DIR}"

run "Removing current spec directory" rm -rf "${SPEC_DIR}"
run "Moving split spec into place" mv "${SPLIT_DIR}" .

echo ""
echo "Split completed"
echo "  Output directory: ${SPEC_DIR}"
echo ""