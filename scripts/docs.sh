
#!/usr/bin/env bash

# Build HTML documentation using Redocly

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

SPEC_FILE="${SPEC_FILE:-./spec/openapi.yaml}"
DOC_DIR="${DOC_DIR:-./docs}"
DOC_FILE="${DOC_FILE:-./docs/index.html}"

print_step "Building HTML documentation"

require_file "${SPEC_FILE}"
ensure_dir "${DOC_DIR}"

run "Running redocly build-docs" \
  npx redocly build-docs "${SPEC_FILE}" -o "${DOC_FILE}"

echo ""
echo "Documentation generated"
echo "  Output: ${DOC_FILE}"
echo ""