#!/usr/bin/env bash

# Start Vacuum dashboard for source or bundled spec

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

scope="${1:-source}"
mode="${2:-standard}"

SPEC_FILE="${SPEC_FILE:-./spec/openapi.yaml}"
BUNDLE_FILE="${BUNDLE_FILE:-./gen/openapi.yaml}"
VACUUM_RULESET="${VACUUM_RULESET:-./cfg/vacuum-ruleset.yaml}"
VACUUM_IGNORE="${VACUUM_IGNORE:-./cfg/vacuum-ignore.yaml}"

spec_path="${SPEC_FILE}"
label="source spec"

if [[ "${scope}" == "bundle" ]]; then
  spec_path="${BUNDLE_FILE}"
  label="bundled spec"
fi

print_step "Starting Vacuum dashboard on ${label}"
echo "  Mode: ${mode}"
echo ""

require_file "${spec_path}"

if [[ "${mode}" == "hard" ]]; then
  run "vacuum dashboard" npx vacuum dashboard "${spec_path}" --ignore-file "${VACUUM_IGNORE}" --hard-mode --watch
else
  run "vacuum dashboard" npx vacuum dashboard "${spec_path}" --ruleset="${VACUUM_RULESET}" --ignore-file "${VACUUM_IGNORE}" --watch
fi