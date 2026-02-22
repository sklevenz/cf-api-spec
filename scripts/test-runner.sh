#!/usr/bin/env bash

set -euo pipefail

# Validate required environment variables
CF_API_URL=http://127.0.0.1:4010
CF_USERNAME=admin
CF_PASSWORD=admin
TESTS_FILE=./mock/tests.yaml

: "${CF_API_URL:?CF_API_URL is required}"
: "${CF_USERNAME:?CF_USERNAME is required}"
: "${CF_PASSWORD:?CF_PASSWORD is required}"
: "${TESTS_FILE:?TESTS_FILE is required}"

# Check dependencies
command -v cf >/dev/null 2>&1 || { echo "cf CLI not found"; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "yq not found"; exit 1; }

# Login to Cloud Foundry
echo "cf api ${CF_API_URL}"
echo "cf auth ${CF_USERNAME} ${CF_PASSWORD}"

# Iterate over tests in YAML file
TEST_COUNT=$(yq '.tests | length' "${TESTS_FILE}")

for ((i=0; i<TEST_COUNT; i++)); do
  PATH_VALUE=$(yq -r ".tests[${i}].path" "${TESTS_FILE}")
  METHOD=$(yq -r ".tests[${i}].method" "${TESTS_FILE}")
  CONTENT_TYPE=$(yq -r ".tests[${i}].\"content-type\"" "${TESTS_FILE}")
  BODY=$(yq -c ".tests[${i}].body" "${TESTS_FILE}")
  PARAMS_COUNT=$(yq ".tests[${i}].param | length" "${TESTS_FILE}" 2>/dev/null || echo 0)
  STATUS=$(yq -c ".tests[${i}].status" "${TESTS_FILE}")
  ACCEPT=$(yq -c ".tests[${i}].accept" "${TESTS_FILE}")

  QUERY_STRING=""

  if [[ "${PARAMS_COUNT}" != "null" && "${PARAMS_COUNT}" -gt 0 ]]; then
    for ((p=0; p<PARAMS_COUNT; p++)); do
      PARAM=$(yq -r ".tests[${i}].param[${p}]" "${TESTS_FILE}")
      if [[ -z "${QUERY_STRING}" ]]; then
        QUERY_STRING="?${PARAM}"
      else
        QUERY_STRING="${QUERY_STRING}&${PARAM}"
      fi
    done
  fi

  FULL_PATH="${PATH_VALUE}${QUERY_STRING}"

  CMD="cf curl -i \"${FULL_PATH}\" -X ${METHOD}"

  if [[ "${ACCEPT}" != "null" && -n "${ACCEPT}" ]]; then
    CMD="${CMD} -H \"Accept: ${ACCEPT}\""
  fi

  if [[ "${CONTENT_TYPE}" != "null" && -n "${CONTENT_TYPE}" ]]; then
    CMD="${CMD} -H \"Content-Type: ${CONTENT_TYPE}\""
  fi

#  if [[ "${BODY}" != "null" && "${BODY}" != "{}" ]]; then
  if [[ "${BODY}" != "null" ]]; then
    CMD="${CMD} -d '${BODY}'"
  fi

  echo "${CMD}"
  RESPONSE=$(eval "${CMD}")

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
