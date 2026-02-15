#!/usr/bin/env bash

# Generate Vacuum ignore file from hard mode report

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SPEC_FILE="${SPEC_FILE:-./spec/openapi.yaml}"
VACUUM_IGNORE="${VACUUM_IGNORE:-./cfg/vacuum-ignore.yaml}"

print_step "Generating Vacuum ignore file"

require_file "${SPEC_FILE}"

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

run "Generating hard mode report" \
  npx vacuum report "${SPEC_FILE}" --stdout --hard-mode > "${tmp}"

run "Generating ignore file" \
  npx vacuum generate-ignorefile "${tmp}" "${VACUUM_IGNORE}"

echo ""
echo "Ignore file generated"
echo "  Output: ${VACUUM_IGNORE}"
echo ""