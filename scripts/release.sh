#!/usr/bin/env bash

set -euo pipefail

# Create a GitHub release with bundled OpenAPI spec and generated docs.
# Usage: ./release.sh
# Requirements: git, gh (authenticated), plus tools required by scripts/lib.sh

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

main() {
  init_common_paths

  require_command git
  require_command gh

  require_file "${SPEC_FILE}"

  # Read release version from spec via shared library function
  local tag
  tag="$(read_version_from_spec "${SPEC_FILE}")"

  # Ensure we are on main branch
  local current_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "${current_branch}" != "main" ]]; then
    fail "Releases are only allowed from main branch. Current branch: ${current_branch}"
  fi

  # Ensure working directory is clean
  if ! git diff-index --quiet HEAD --; then
    fail "Working directory is dirty. Please commit or stash changes before releasing."
  fi

  # Ensure no local tag exists
  if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
    fail "Git tag already exists: ${tag}"
  fi

  # Ensure no remote tag exists
  if git ls-remote --tags origin "refs/tags/${tag}" | grep -q .; then
    fail "Remote git tag already exists: ${tag}"
  fi

  # Ensure no GitHub release exists
  if gh release view "${tag}" >/dev/null 2>&1; then
    fail "GitHub release already exists: ${tag}"
  fi

  local openapi_src
  openapi_src="${BUNDLE_FILE}"

  local docs_src
  docs_src="${DOC_DIR}/cf-api-openapi-${tag}.html"

  require_file "${openapi_src}"
  require_file "${docs_src}"

  ensure_dir "${GEN_DIR}"

  local openapi_out
  openapi_out="${GEN_DIR}/cf-api-openapi-${tag}.yaml"

  local docs_out
  docs_out="${GEN_DIR}/cf-api-openapi-${tag}.html"

  run "Copying OpenAPI bundle" cp "${openapi_src}" "${openapi_out}"
  run "Copying HTML docs" cp "${docs_src}" "${docs_out}"

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
}

main "$@"