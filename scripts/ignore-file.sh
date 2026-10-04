#!/usr/bin/env bash

set -euo pipefail

# Generate a Vacuum ignore file based on a hard mode report.
# Requirements: node, npx
# Output: ${VACUUM_IGNORE}

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"
init_common_paths

if ! command -v npx >/dev/null 2>&1; then
  fail "npx is required to run vacuum report and generate-ignorefile"
fi

main() {
  print_step "Generating Vacuum ignore file"

  require_file "${SPEC_FILE}"

  ensure_dir "$(dirname "${VACUUM_IGNORE}")"

  local tmp
  tmp="$(mktemp)"

  # Expand the temp file path now, otherwise "local tmp" goes out of scope and set -u will fail at EXIT.
  trap "rm -f \"${tmp}\"" EXIT

  run "Generating hard mode report" \
    bash -c 'npx --yes vacuum report -o -n -q --hard-mode "$1" > "$2"' _ "${SPEC_FILE}" "${tmp}"

  run "Generating ignore file" \
    npx --yes vacuum generate-ignorefile "${tmp}" "${VACUUM_IGNORE}"

  echo ""
  echo "Ignore file generated"
  echo "  Output: ${VACUUM_IGNORE}"
  echo ""
}

main "$@"