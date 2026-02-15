#!/usr/bin/env bash

# Run Vacuum linter for source or bundled spec

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths

scope="${1:-source}"
mode="${2:-standard}"


spec_path="${SPEC_FILE}"
label="source spec"

if [[ "${scope}" == "bundle" ]]; then
  spec_path="${BUNDLE_FILE}"
  label="bundled spec"
fi

if [[ "${mode}" == "hard" ]]; then
  print_step "Running Vacuum linter in hard mode on ${label}"
  require_file "${spec_path}"
  run "vacuum lint" npx vacuum lint "${spec_path}" --hard-mode --ignore-file "${VACUUM_IGNORE}"
else
  print_step "Running Vacuum linter on ${label}"
  require_file "${spec_path}"
  run "vacuum lint" npx vacuum lint "${spec_path}" --ruleset="${VACUUM_RULESET}" --ignore-file "${VACUUM_IGNORE}"
fi

echo ""