#!/usr/bin/env bash

# Install or update CLI tools locally

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths

print_step "Installing CLI tools locally"

run "npm install" \
  npm install --no-save @redocly/cli @stoplight/prism-cli @quobix/vacuum

print_step "Installed tool versions"

run "Redocly version" npx redocly --version
run "Prism version" npx prism --version
run "Vacuum version" npx vacuum version

echo ""