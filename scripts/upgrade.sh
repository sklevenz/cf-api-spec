#!/usr/bin/env bash

# Install or update CLI tools locally

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

print_step "Installing CLI tools locally"

run "npm install" \
  npm install --no-save @redocly/cli @stoplight/prism-cli @quobix/vacuum

print_step "Installed tool versions"

printf "  Redocly  %s\n" "$(npx redocly --version)"
printf "  Prism    %s\n" "$(npx prism --version)"
printf "  Vacuum   %s\n" "$(npx vacuum version)"
echo ""