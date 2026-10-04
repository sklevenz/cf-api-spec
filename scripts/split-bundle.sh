#!/usr/bin/env bash

# Split the bundled OpenAPI spec back into the file structure.
# Usage: ./split-bundle.sh
# Requirements: node, npx
# Output: ${SPEC_DIR}

set -euo pipefail

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

main() {
  init_common_paths
  require_command npx

  set_default SPLIT_DIR "${GEN_DIR}/spec"

  print_step "Splitting bundled OpenAPI specification"

  require_file "${BUNDLE_FILE}"

  run "Removing previous split output" rm -rf "${SPLIT_DIR}"

  run "Running redocly split" \
    npx --yes @redocly/cli split "${BUNDLE_FILE}" --outDir "${SPLIT_DIR}"

  run "Removing current spec directory" rm -rf "${SPEC_DIR}"
  run "Moving split spec into place" mv "${SPLIT_DIR}" .

  echo ""
  echo "Split completed"
  echo "  Output directory: ${SPEC_DIR}"
  echo ""
}

main "$@"