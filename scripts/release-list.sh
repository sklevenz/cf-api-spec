#!/usr/bin/env bash

set -euo pipefail

# List GitHub releases for this repository.
# Usage: ./release-list.sh [additional gh args]
# Requirements: gh (authenticated)

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

main() {
  require_command gh

  print_step "Listing GitHub releases"

  # Pass through any additional arguments to gh
  gh release list "$@"
}

main "$@"
