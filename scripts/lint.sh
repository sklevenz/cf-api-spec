#!/usr/bin/env bash

# Script to lint the OpenAPI specification using Spectral

# Suppress warnings for Node.js
export NODE_NO_WARNINGS=1

# Variables
SPEC_FILE="spec/openapi.yaml"                       # Path to the OpenAPI spec
LINTER="spectral"                                   # Linter command
RULESET="scripts/cfg/spectral-ruleset-simple.yaml"  # Default ruleset for OpenAPI
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Check if Spectral is installed
if ! command -v $LINTER &> /dev/null; then
  echo "Error: Spectral is not installed."
  echo "Install it with:"
  echo "  npm install -g @stoplight/spectral-cli"
  exit $EXIT_FAILURE
fi

# Check if the spec file exists
if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: OpenAPI spec file not found at $SPEC_FILE."
  exit $EXIT_FAILURE
fi

# Run Spectral lint
echo "Linting OpenAPI spec at: $SPEC_FILE"
$LINTER lint --ruleset "$RULESET" "$SPEC_FILE"

# Check the exit status of Spectral
if [ $? -eq $EXIT_SUCCESS ]; then
  echo "Linting passed: The OpenAPI spec is valid and adheres to best practices."
  exit $EXIT_SUCCESS
else
  echo "Linting failed: Please fix the issues reported by Spectral."
  exit $EXIT_FAILURE
fi