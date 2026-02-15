#!/usr/bin/env bash

# Enable strict mode
set -euo pipefail

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