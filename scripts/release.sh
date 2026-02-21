#!/usr/bin/env bash

# Create a GitHub release with bundled OpenAPI spec and generated docs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths

# Read release version from spec (source of truth)
require_file "${SPEC_FILE}"

if ! command -v yq >/dev/null 2>&1; then
  fail "yq is required to read info.version from ${SPEC_FILE}"
fi

TAG="$(yq e '.info.version' "${SPEC_FILE}")"

if [[ "${TAG}" == "null" || -z "${TAG}" ]]; then
  fail "Could not read info.version from ${SPEC_FILE}"
fi

# Ensure we are on main branch
current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${current_branch}" != "main" ]]; then
  fail "Releases are only allowed from main branch. Current branch: ${current_branch}"
fi

# Ensure working directory is clean
if ! git diff-index --quiet HEAD --; then
  fail "Working directory is dirty. Please commit or stash changes before releasing."
fi

# Ensure no local tag exists
if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  fail "Git tag already exists: ${TAG}"
fi

# Ensure no remote tag exists
if git ls-remote --tags origin "refs/tags/${TAG}" | grep -q .; then
  fail "Remote git tag already exists: ${TAG}"
fi

# Ensure no GitHub release exists
if gh release view "${TAG}" >/dev/null 2>&1; then
  fail "GitHub release already exists: ${TAG}"
fi

tag="${TAG}"
openapi_src="${BUNDLE_FILE}"
docs_src="${DOC_FILE}"

require_file "${openapi_src}"
require_file "${docs_src}"
ensure_dir "${GEN_DIR}"

openapi_out="${GEN_DIR}/cf-api-openapi-${tag}.yaml"
docs_out="${GEN_DIR}/cf-api-openapi-${tag}.html"

run "Copying release artifacts" cp "${openapi_src}" "${openapi_out}"
run "Copying release artifacts" cp "${docs_src}" "${docs_out}"

print_step "Preparing GitHub release"

echo ""
echo "About to create GitHub release"
echo "  Tag: ${tag}"
echo "  Target: main"
echo "  Title: ${tag}"
echo "  Assets:"
echo "    ${openapi_out}"
echo "    ${docs_out}"
echo ""

read -r -p "Proceed with creating the GitHub release? (y/N): " confirm
if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
  echo "Aborted"
  exit 1
fi

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