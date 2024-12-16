#!/usr/bin/env bash

# Suppress Node.js warnings
export NODE_NO_WARNINGS=1

# Path to the OpenAPI specification file
SPEC_FILE="spec/openapi.yaml"

# Check if swagger-cli is installed
if ! command -v swagger-cli &> /dev/null; then
  echo "swagger-cli is not installed. Install it using: npm install -g @apidevtools/swagger-cli."
  exit 1
fi

# Validate the OpenAPI specification
echo "Validating OpenAPI specification at $SPEC_FILE..."
swagger-cli validate "$SPEC_FILE"

# Check the result of the validation
if [ $? -eq 0 ]; then
  echo "The OpenAPI specification is valid."
  exit 0
else
  echo "OpenAPI specification validation failed."
  exit 1
fi