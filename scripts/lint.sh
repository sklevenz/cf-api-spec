#!/usr/bin/env bash

set -euo pipefail

# Run Vacuum linter for the source or bundled specification.
# Usage: ./lint.sh [source|bundle] [standard|hard]
# Requirements: node, npx

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

init_common_paths

require_command npx

main() {
  local scope="${1:-source}"
  local mode="${2:-standard}"

  local spec_path="${SPEC_FILE}"
  local label="source spec"

  if [[ "${scope}" == "bundle" ]]; then
    spec_path="${BUNDLE_FILE}"
    label="bundled spec"
  elif [[ "${scope}" != "source" ]]; then
    fail "Invalid scope: ${scope} (expected: source or bundle)"
  fi

  if [[ "${mode}" != "standard" && "${mode}" != "hard" ]]; then
    fail "Invalid mode: ${mode} (expected: standard or hard)"
  fi

  require_file "${spec_path}"

  if [[ "${mode}" == "hard" ]]; then
    print_step "Running Vacuum linter in hard mode on ${label}"
    run "vacuum lint" \
      npx --yes vacuum lint "${spec_path}" \
        --hard-mode \
        --ignore-file "${VACUUM_IGNORE}"
  else
    print_step "Running Vacuum linter on ${label}"
    run "vacuum lint" \
      npx --yes vacuum lint "${spec_path}" \
        --ruleset="${VACUUM_RULESET}" \
        --ignore-file "${VACUUM_IGNORE}"
  fi

  echo ""
}

main "$@"