#!/usr/bin/env bash

# Script to lint the OpenAPI specification using Spectral

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Variables
SPEC_FILE="spec/openapi.yaml"                  # Path to your OpenAPI spec
LINTER="spectral"                              # Linter command
RULESET="scripts/cfg/spectral-ruleset.yaml"    # Default ruleset for OpenAPI
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Check if Spectral is installed
if ! command -v $LINTER &> /dev/null; then
  echo -e "${RED}Error: Spectral is not installed.${RESET}"
  echo "Install it with:"
  echo "  npm install -g @stoplight/spectral-cli"
  exit $EXIT_FAILURE
fi

# Check if the spec file exists
if [ ! -f "$SPEC_FILE" ]; then
  echo -e "${RED}Error: OpenAPI spec file not found at $SPEC_FILE.${RESET}"
  exit $EXIT_FAILURE
fi

# Run Spectral lint
echo "Linting OpenAPI spec at: $SPEC_FILE"
$LINTER lint --ruleset "$RULESET" "$SPEC_FILE"

# Check the exit status of Spectral
if [ $? -eq $EXIT_SUCCESS ]; then
  echo -e "${GREEN}Linting passed: The OpenAPI spec is valid and adheres to best practices.${RESET}"
  exit $EXIT_SUCCESS
else
  echo -e "${RED}Linting failed: Please fix the issues reported by Spectral.${RESET}"
  exit $EXIT_FAILURE
fi