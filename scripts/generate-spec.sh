#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Set variables
SPEC_FILE="spec/openapi.yaml"
OUTPUT_DIR="gen"
OUTPUT_FILE="$OUTPUT_DIR/cf-api-openapi.yaml"
LINTER="spectral"                              # Linter command
RULESET="scripts/cfg/spectral-ruleset.yaml"    # Default ruleset for OpenAPI
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Ensure the spec file exists
if [[ ! -f "$SPEC_FILE" ]]; then
  echo -e "${RED}Error: Spec file '$SPEC_FILE' does not exist. Please provide a valid OpenAPI file.${RESET}"
  exit $EXIT_FAILURE
fi

# Create the output directory if it doesn't exist
if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Output directory '$OUTPUT_DIR' does not exist. Creating it..."
  if ! mkdir -p "$OUTPUT_DIR"; then
    echo -e "${RED}Error: Failed to create output directory '$OUTPUT_DIR'.${RESET}"
    exit $EXIT_FAILURE
  fi
fi

# Bundle the OpenAPI specification
if swagger-cli bundle "$SPEC_FILE" > "$OUTPUT_FILE"; then
  echo -e "${GREEN}Specification generated successfully: $OUTPUT_FILE${RESET}"
else
  echo -e "${RED}Error: Failed to generate specification. Please check the OpenAPI file and swagger-cli installation.${RESET}"
  exit $EXIT_FAILURE
fi


# Validate the OpenAPI spec
echo "Validating OpenAPI spec at $OUTPUT_FILE..."
swagger-cli validate "$OUTPUT_FILE"

# Exit with the result of the validation
if [ $? -eq 0 ]; then
  echo -e "${GREEN}OpenAPI spec is valid!${RESET}"
else
  echo -e "${RED}OpenAPI spec validation failed.${RESET}"
  exit $EXIT_FAILURE
fi


$LINTER lint --ruleset "$RULESET" "$OUTPUT_FILE"

# Check the exit status of Spectral
if [ $? -eq $EXIT_SUCCESS ]; then
  echo -e "${GREEN}Linting passed: The OpenAPI spec is valid and adheres to best practices.${RESET}"
  exit $EXIT_SUCCESS
else
  echo -e "${RED}Linting failed: Please fix the issues reported by Spectral.${RESET}"
  exit $EXIT_FAILURE
fi