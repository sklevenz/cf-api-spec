#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail

# Set a default value for an env var if it is empty or unset
set_default() {
  local var_name="${1:?var_name missing}"
  local default_value="${2-}"

  # Indirect expansion to read current value
  local current_value="${!var_name-}"
  if [[ -z "${current_value}" ]]; then
    printf -v "${var_name}" '%s' "${default_value}"
    export "${var_name}"
  fi
}

# Initialize common project paths and files
init_common_paths() {
  set_default SPEC_DIR "./spec"
  set_default GEN_DIR "./gen"

  set_default SPEC_FILE "${SPEC_DIR}/openapi.yaml"
  set_default BUNDLE_FILE "${GEN_DIR}/openapi.yaml"

  set_default DOC_DIR "./docs"

  set_default VACUUM_RULESET "./cfg/vacuum-ruleset.yaml"
  set_default VACUUM_IGNORE "./cfg/vacuum-ignore.yaml"
}

# Print a section header
print_step() {
  local message="${1:-}"
  echo ""
  echo "$message"
}

# Print an error message and exit
fail() {
  local message="${1:-Unknown error}"
  echo ""
  echo "Error"
  echo "  ${message}"
  exit 1
}

# Check that a file exists
require_file() {
  local file_path="${1:-}"
  if [[ -z "${file_path}" ]]; then
    fail "No file path provided to require_file"
  fi
  if [[ ! -f "${file_path}" ]]; then
    fail "File not found at ${file_path}"
  fi
}

# Check that a directory exists
require_dir() {
  local dir_path="${1:-}"
  if [[ -z "${dir_path}" ]]; then
    fail "No directory path provided to require_dir"
  fi
  if [[ ! -d "${dir_path}" ]]; then
    fail "Directory not found at ${dir_path}"
  fi
}

# Create directory if it does not exist
ensure_dir() {
  local dir_path="${1:-}"
  if [[ -z "${dir_path}" ]]; then
    fail "No directory path provided to ensure_dir"
  fi
  mkdir -p "${dir_path}"
}

# Run a command and print a friendly failure message if it exits non zero
run() {
  local description="${1:-Running command}"
  shift
  print_step "${description}"
  if ! "$@"; then
    fail "Command failed: $*"
  fi
}

# Print success message
success() {
  local message="${1:-Done}"
  echo ""
  echo "${message}"
  echo ""
}

# Return list all releases echo "${releases[@]}"
get_releases() {
  mapfile -t releases < <(
    gh release list --json tagName --limit 100 \
    | jq -r '.[].tagName'
  )
}

# Read version property from spec file
read_version_from_spec() {
  local spec_file="$1"

  require_file "${spec_file}"

  if ! command -v yq >/dev/null 2>&1; then
    fail "yq is required to read info.version from ${spec_file}"
  fi

  local tag
  tag="$(yq e '.info.version' "${spec_file}")"

  if [[ "${tag}" == "null" || -z "${tag}" ]]; then
    fail "Could not read info.version from ${spec_file}"
  fi

  echo "${tag}"
}