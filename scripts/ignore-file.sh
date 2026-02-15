#!/usr/bin/env bash

# Generate Vacuum ignore file from hard mode report

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"
init_common_paths

print_step "Generating Vacuum ignore file"

require_file "${SPEC_FILE}"

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

run "Generating hard mode report" \
  bash -c 'npx vacuum report -o -n -q --hard-mode "$1" > "$2"' _ "${SPEC_FILE}" "${tmp}"

run "Generating ignore file" \
  npx vacuum generate-ignorefile "${tmp}" "${VACUUM_IGNORE}"

echo ""
echo "Ignore file generated"
echo "  Output: ${VACUUM_IGNORE}"
echo ""