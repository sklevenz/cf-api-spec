#!/usr/bin/env bash

set -euo pipefail

# Build HTML documentation for the current spec and download docs for existing releases.
# Output: ${DOC_DIR}/index.html and ${DOC_DIR}/cf-api-openapi-<version>.html
# Requirements: node, npx, wget

render_index_html() {
  local output_file="$1"
  local dev_version="$2"

  {
    echo '<!doctype html>'
    echo '<html lang="en">'
    echo '  <head>'
    echo '    <meta charset="utf-8" />'
    echo '    <meta name="viewport" content="width=device-width,initial-scale=1" />'
    echo '    <title>Cloud Foundry OpenAPI Specification</title>'
    echo '  </head>'
    echo '  <body>'
    echo '    <h1>Cloud Foundry OpenAPI Specification</h1>'
    echo ''
    echo '    <ul>'

    echo "      <li><a href=\"./cf-api-openapi-${dev_version}.html\">${dev_version} (dev)</a></li>"

    for release in "${releases[@]}"; do
      echo "      <li><a href=\"./cf-api-openapi-${release}.html\">${release}</a></li>"
    done

    echo '    </ul>'
    echo '  </body>'
    echo '</html>'
  } > "${output_file}"
}

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"

init_common_paths

if ! command -v npx >/dev/null 2>&1; then
  fail "npx is required to build HTML docs"
fi

if ! command -v wget >/dev/null 2>&1; then
  fail "wget is required to download release docs"
fi

get_releases

main() {
  print_step "Building HTML documentation"

  require_file "${SPEC_FILE}"
  ensure_dir "${DOC_DIR}"

  local dev_version
  dev_version="$(read_version_from_spec "${SPEC_FILE}")"

  # Build the documentation for the current dev version
  set_default DOC_FILE "${DOC_DIR}/cf-api-openapi-${dev_version}.html"

  run "Running redocly build-docs" \
    npx --yes @redocly/cli build-docs "${SPEC_FILE}" -o "${DOC_FILE}"

  # Download docs for all existing releases
  for release in "${releases[@]}"; do
    local outfile
    outfile="${DOC_DIR}/cf-api-openapi-${release}.html"

    wget -q \
      "https://github.com/sklevenz/cf-api-spec/releases/download/${release}/cf-api-openapi-${release}.html" \
      --output-document="${outfile}"

    echo "Release: ${outfile}"
  done

  render_index_html "${DOC_DIR}/index.html" "${dev_version}"

  echo ""
  echo "Documentation generated: ${DOC_DIR}/index.html"
  echo ""
}

main "$@"
