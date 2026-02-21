#!/usr/bin/env bash

set -euo pipefail

# Start a local Prism mock server for the combined CF and UAA specifications.
# Usage: ./mock.sh
# Requirements: node, npx

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"
init_common_paths

require_command npx

main() {
  set_default UAA_SPEC_FILE "./mock/uaa.yaml"
  set_default MOCK_SPEC_FILE "${GEN_DIR}/openapi-mock.yaml"
  set_default MOCK_PORT "4010"

  print_step "Starting Prism mock server"

  require_file "${SPEC_FILE}"
  require_file "${UAA_SPEC_FILE}"
  ensure_dir "${GEN_DIR}"

  run "Joining OpenAPI specs" \
    npx --yes @redocly/cli join "${SPEC_FILE}" "${UAA_SPEC_FILE}" -o "${MOCK_SPEC_FILE}"

  run "Starting Prism mock server" \
    npx --yes @stoplight/prism-cli mock "${MOCK_SPEC_FILE}" --port "${MOCK_PORT}"
}

main "$@"