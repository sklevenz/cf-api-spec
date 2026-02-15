#!/usr/bin/env bash

# Start local Prism mock server for combined CF and UAA spec

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"
init_common_paths
set_default UAA_SPEC_FILE "./mock/uaa.yaml"
set_default MOCK_SPEC_FILE "${GEN_DIR}/openapi-mock.yaml"
set_default MOCK_PORT "4010"

print_step "Starting Prism mock server"

require_file "${SPEC_FILE}"
require_file "${UAA_SPEC_FILE}"
ensure_dir "${GEN_DIR}"

run "Joining OpenAPI specs" \
  npx -y @redocly/cli join "${SPEC_FILE}" "${UAA_SPEC_FILE}" -o "${MOCK_SPEC_FILE}"

run "Starting Prism mock server" \
  npx prism mock "${MOCK_SPEC_FILE}" --port "${MOCK_PORT}"