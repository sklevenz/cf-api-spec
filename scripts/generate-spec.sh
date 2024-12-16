#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Set variables
SPEC_FILE="spec/openapi.yaml"
OUTPUT_DIR="gen"
OUTPUT_FILE="$OUTPUT_DIR/cf-api-openapi-generated.yaml"
LINTER="spectral"                              # Linter command
RULESET="scripts/cfg/spectral-ruleset.yaml"    # Default ruleset for OpenAPI
EXIT_SUCCESS=0
EXIT_FAILURE=1

# Ensure the spec file exists
if [[ ! -f "$SPEC_FILE" ]]; then
  echo "Error: Spec file '$SPEC_FILE' does not exist. Please provide a valid OpenAPI file."
  exit $EXIT_FAILURE
fi

# Delete output file 
rm -f "$OUTPUT_FILE"

# Create the output directory if it doesn't exist
if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Output directory '$OUTPUT_DIR' does not exist. Creating it..."
  if ! mkdir -p "$OUTPUT_DIR"; then
    echo "Error: Failed to create output directory '$OUTPUT_DIR'."
    exit $EXIT_FAILURE
  fi
fi

# Bundle the OpenAPI specification
if swagger-cli bundle "$SPEC_FILE" > "$OUTPUT_FILE"; then
  echo "Specification generated successfully: $OUTPUT_FILE"
else
  echo "Error: Failed to generate specification. Please check the OpenAPI file and swagger-cli installation."
  exit $EXIT_FAILURE
fi

# Validate the OpenAPI spec
echo "Validating OpenAPI spec at $OUTPUT_FILE..."
swagger-cli validate "$OUTPUT_FILE"

# Exit with the result of the validation
if [ $? -eq 0 ]; then
  echo "OpenAPI spec is valid!"
else
  echo "OpenAPI spec validation failed."
  exit $EXIT_FAILURE
fi

# Lint the specification with Spectral - handle warnings as errors
$LINTER lint --fail-severity=warn --ruleset "$RULESET" "$OUTPUT_FILE"

# Check the exit status of Spectral
if [ $? -eq $EXIT_SUCCESS ]; then
  echo "Linting passed: The OpenAPI spec is valid and adheres to best practices."
  exit $EXIT_SUCCESS
else
  echo "Linting failed: Please fix the issues reported by Spectral."
  exit $EXIT_FAILURE
fi