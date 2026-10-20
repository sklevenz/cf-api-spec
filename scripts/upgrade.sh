#!/usr/bin/env bash

set -euo pipefail

# Install or update local CLI tools used by this repository.
# Usage: ./upgrade.sh
# Requirements: npm, npx

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

main() {
  init_common_paths

  require_command npm
  require_command npx

  print_step "Installing CLI tools locally"

  run "npm install" \
    npm install --no-save @redocly/cli @stoplight/prism-cli @quobix/vacuum

  print_step "Installed tool versions"

  run "Redocly version" npx --yes @redocly/cli --version
  run "Prism version" npx --yes @stoplight/prism-cli --version
  run "Vacuum version" npx --yes @quobix/vacuum version

  echo ""
}

main "$@"