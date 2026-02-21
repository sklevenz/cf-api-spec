#!/usr/bin/env bash

set -euo pipefail

# Start Vacuum dashboard for the source or bundled specification.
# Usage: ./dashboard.sh [source|bundle] [standard|hard]
# Requirements: node, npx

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"
init_common_paths

if ! command -v npx >/dev/null 2>&1; then
  fail "npx is required to run vacuum dashboard"
fi

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

  print_step "Starting Vacuum dashboard on ${label}"
  echo "  Mode: ${mode}"
  echo ""

  require_file "${spec_path}"

  if [[ "${mode}" == "hard" ]]; then
    run "vacuum dashboard" \
      npx --yes vacuum dashboard "${spec_path}" \
        --ignore-file "${VACUUM_IGNORE}" \
        --hard-mode \
        --watch
  else
    run "vacuum dashboard" \
      npx --yes vacuum dashboard "${spec_path}" \
        --ruleset="${VACUUM_RULESET}" \
        --ignore-file "${VACUUM_IGNORE}" \
        --watch
  fi
}

main "$@"