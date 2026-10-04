#!/usr/bin/env bash

set -euo pipefail

# Calculate the next patch version based on info.version in the OpenAPI spec.
# Usage: ./next-version.sh
# Output: prints next version to stdout

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

main() {
  init_common_paths

  require_file "${SPEC_FILE}"

  local current_version
  current_version="$(read_version_from_spec "${SPEC_FILE}")"

  # Expect semantic version in format X.Y.Z
  local major minor patch
  IFS='.' read -r major minor patch <<< "${current_version}"

  if [[ -z "${major:-}" || -z "${minor:-}" || -z "${patch:-}" ]]; then
    fail "Version '${current_version}' is not in semantic format X.Y.Z"
  fi

  # Ensure numeric patch version
  if ! [[ "${patch}" =~ ^[0-9]+$ ]]; then
    fail "Patch version '${patch}' is not numeric"
  fi

  local next_patch
  next_patch="$((patch + 1))"

  local next_version
  next_version="${major}.${minor}.${next_patch}"

  # Write new version back to spec file
  run "Updating spec version" \
    yq e -i ".info.version = \"${next_version}\"" "${SPEC_FILE}"

  echo ""
  echo "Version updated in spec file"
  echo "  File: ${SPEC_FILE}"
  echo "  New version: ${next_version}"
  echo ""
  echo "Please commit the version change manually."
  echo ""
}

main "$@"