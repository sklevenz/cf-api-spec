#!/usr/bin/env bash

# Render index.html for OpenAPI documentation
# Expects: releases array (e.g. alpha-0.0.4 alpha-0.0.3 ...)
# Usage: render_index_html "./gen/docs/index.html"

render_index_html() {
  local output_file="$1"

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

    echo "      <li><a href=\"./cf-api-openapi-${DEV_VERSION}.html\">${DEV_VERSION} (dev)</a></li>"

    for release in "${releases[@]}"; do
      echo "      <li><a href=\"./cf-api-openapi-${release}.html\">${release}</a></li>"
    done

    echo '    </ul>'
    echo '  </body>'
    echo '</html>'
  } > "${output_file}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${SCRIPT_DIR}/lib.sh"

init_common_paths
get_releases

print_step "Building HTML documentation"

require_file "${SPEC_FILE}"
ensure_dir "${DOC_DIR}"

# Read release version from spec via shared library function
DEV_VERSION="$(read_version_from_spec "${SPEC_FILE}")"

# Build the development release
run "Running redocly build-docs" \
  set_default DOC_FILE "${DOC_DIR}/cf-api-openapi-$DEV_VERSION.html"
  npx redocly build-docs "${SPEC_FILE}" -o "${DOC_FILE}"

# Download all release doc files
# Iterate over all releases
for release in "${releases[@]}"; do
  outfile="$DOC_DIR/cf-api-openapi-"$release".html"
  wget "https://github.com/sklevenz/cf-api-spec/releases/download/"$release"/cf-api-openapi-"$release".html" --output-document="$outfile"
  echo "Release: ${outfile}"
done

render_index_html "${DOC_DIR}/index.html"

echo ""
echo "Documentation generated: ${DOC_DIR}/index.html"
echo ""
