#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Define the OpenAPI spec file
SPEC_FILE="spec/openapi.yaml"

# Check if swagger-cli is installed
if ! command -v swagger-cli &> /dev/null; then
  echo "swagger-cli is not installed. Install it using 'npm install -g @apidevtools/swagger-cli'."
  exit 1
fi

# Validate the OpenAPI spec
echo "Validating OpenAPI spec at $SPEC_FILE..."
swagger-cli validate "$SPEC_FILE"

# Exit with the result of the validation
if [ $? -eq 0 ]; then
  echo "OpenAPI spec is valid!"
  exit 0
else
  echo "OpenAPI spec validation failed."
  exit 1
fi
