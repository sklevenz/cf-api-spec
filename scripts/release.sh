#!/usr/bin/env bash

# Create a GitHub release with bundled OpenAPI spec and generated docs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths
VERSION="${VERSION:-}"


if [[ -z "${VERSION}" ]]; then
  fail "VERSION is required, use: make release VERSION=0.0.0"
fi

tag="${VERSION}"
openapi_src="${BUNDLE_FILE}"
docs_src="${DOC_FILE}"

require_file "${openapi_src}"
require_file "${docs_src}"
ensure_dir "${GEN_DIR}"

openapi_out="${GEN_DIR}/cf-api-openapi-${tag}.yaml"
docs_out="${GEN_DIR}/cf-api-openapi-${tag}.html"

run "Copying release artifacts" cp "${openapi_src}" "${openapi_out}"
run "Copying release artifacts" cp "${docs_src}" "${docs_out}"

print_step "Creating GitHub release ${tag}"

run "gh release create" gh release create "${tag}" "${openapi_out}" "${docs_out}" \
  --title "${tag}" \
  --target main \
  --latest \
  --generate-notes

echo ""
echo "Release created"
echo "  Tag: ${tag}"
echo "  Assets:"
echo "    ${openapi_out}"
echo "    ${docs_out}"
echo ""