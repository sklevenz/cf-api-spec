#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "${script_dir}/lib.sh"
init_common_paths

# Defaults, can be overridden via environment variables
: "${CF_API_URL:=http://127.0.0.1:4010}"
: "${CF_USERNAME:=admin}"
: "${CF_PASSWORD:=admin}"
: "${TESTS_FILE:=./mock/tests.yaml}"

# Validate required environment variables (after defaults)
: "${CF_API_URL:?CF_API_URL is required}"
: "${CF_USERNAME:?CF_USERNAME is required}"
: "${CF_PASSWORD:?CF_PASSWORD is required}"
: "${TESTS_FILE:?TESTS_FILE is required}"

# Check dependencies
command -v cf >/dev/null 2>&1 || { echo "cf CLI not found"; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "yq not found"; exit 1; }

# Check if mock server is reachable
if ! curl -sf "${CF_API_URL}" >/dev/null 2>&1; then
  echo "Mock server not reachable at ${CF_API_URL}"
  echo "Please start it in another terminal using: make mock"
  exit 1
fi

# Login to Cloud Foundry
cf logout >/dev/null 2>&1 || true
cf api "${CF_API_URL}"
cf auth "${CF_USERNAME}" "${CF_PASSWORD}"

# Iterate over tests in YAML file
TEST_COUNT=$(yq '.tests | length' "${TESTS_FILE}")

for ((i=0; i<TEST_COUNT; i++)); do
  PATH_VALUE=$(yq -r ".tests[${i}].path" "${TESTS_FILE}")
  METHOD=$(yq -r ".tests[${i}].method" "${TESTS_FILE}")
  CONTENT_TYPE=$(yq -r ".tests[${i}].\"content-type\"" "${TESTS_FILE}")
  BODY=$(yq -c ".tests[${i}].body" "${TESTS_FILE}")
  PARAMS_COUNT=$(yq ".tests[${i}].param | length" "${TESTS_FILE}" 2>/dev/null || echo 0)

  # Use raw output for scalars to avoid JSON quotes in headers and status comparisons
  STATUS=$(yq -r ".tests[${i}].status" "${TESTS_FILE}")
  ACCEPT=$(yq -r ".tests[${i}].accept" "${TESTS_FILE}")

  QUERY_STRING=""

  if [[ "${PARAMS_COUNT}" != "null" && "${PARAMS_COUNT}" -gt 0 ]]; then
    for ((p=0; p<PARAMS_COUNT; p++)); do
      PARAM=$(yq -r ".tests[${i}].param[${p}]" "${TESTS_FILE}")

      # Some test definitions include quoted values like lifecycle_type="buildpack".
      # When we don't use `eval`, these quotes would be sent literally and break enum validation.
      # Unquote only the value part (keep commas etc. intact).
      KEY="${PARAM%%=*}"
      VALUE="${PARAM#*=}"
      VALUE="${VALUE//\\\"/\"}"
      if [[ "${VALUE}" == \"*\" && "${VALUE}" == *\" ]]; then
        VALUE="${VALUE#\"}"
        VALUE="${VALUE%\"}"
      fi
      PARAM="${KEY}=${VALUE}"

      if [[ -z "${QUERY_STRING}" ]]; then
        QUERY_STRING="?${PARAM}"
      else
        QUERY_STRING="${QUERY_STRING}&${PARAM}"
      fi
    done
  fi

  FULL_PATH="${PATH_VALUE}${QUERY_STRING}"

  cmd=(cf curl -i "${FULL_PATH}" -X "${METHOD}")

  if [[ "${ACCEPT}" != "null" && -n "${ACCEPT}" ]]; then
    cmd+=(-H "Accept: ${ACCEPT}")
  fi

  if [[ "${CONTENT_TYPE}" != "null" && -n "${CONTENT_TYPE}" ]]; then
    cmd+=(-H "Content-Type: ${CONTENT_TYPE}")
  fi

  if [[ "${BODY}" != "null" ]]; then
    cmd+=(-d "${BODY}")
  fi

  printf 'Running:'
  printf ' %q' "${cmd[@]}"
  echo

  RESPONSE=$("${cmd[@]}")

  # Extract HTTP status code from response headers
  HTTP_STATUS=$(echo "${RESPONSE}" | head -n 1 | awk '{print $2}')

  # Validate expected status code
  if [[ "${HTTP_STATUS}" != "${STATUS}" ]]; then
    echo $RESPONSE
    echo "Test $((i+1)) failed: expected status ${STATUS}, got ${HTTP_STATUS}"
    exit 1
  else
    echo "Test $((i+1)) passed: status ${HTTP_STATUS}"
  fi
done
