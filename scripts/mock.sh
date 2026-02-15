#!/usr/bin/env bash

# Start local Prism mock server for combined CF and UAA spec

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SPEC_FILE="${SPEC_FILE:-./spec/openapi.yaml}"
UAA_SPEC_FILE="${UAA_SPEC_FILE:-./mock/uaa.yaml}"
GEN_DIR="${GEN_DIR:-./gen}"
MOCK_SPEC_FILE="${MOCK_SPEC_FILE:-./gen/openapi-mock.yaml}"
MOCK_PORT="${MOCK_PORT:-4010}"

print_step "Starting Prism mock server"

require_file "${SPEC_FILE}"
require_file "${UAA_SPEC_FILE}"
ensure_dir "${GEN_DIR}"

run "Joining OpenAPI specs" \
  npx -y @redocly/cli join "${SPEC_FILE}" "${UAA_SPEC_FILE}" -o "${MOCK_SPEC_FILE}"

run "Starting Prism mock server" \
  npx prism mock "${MOCK_SPEC_FILE}" --port "${MOCK_PORT}"