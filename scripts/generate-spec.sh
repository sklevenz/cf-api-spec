#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Set variables
SPEC_FILE="spec/openapi.yaml"
OUTPUT_DIR="gen"
OUTPUT_FILE="$OUTPUT_DIR/cf-api-openapi.yaml"

# Ensure the spec file exists
if [[ ! -f "$SPEC_FILE" ]]; then
  echo "Error: Spec file '$SPEC_FILE' does not exist. Please provide a valid OpenAPI file."
  exit 1
fi

# Create the output directory if it doesn't exist
if [[ ! -d "$OUTPUT_DIR" ]]; then
  echo "Output directory '$OUTPUT_DIR' does not exist. Creating it..."
  if ! mkdir -p "$OUTPUT_DIR"; then
    echo "Error: Failed to create output directory '$OUTPUT_DIR'."
    exit 1
  fi
fi

# Bundle the OpenAPI specification
if swagger-cli bundle "$SPEC_FILE" > "$OUTPUT_FILE"; then
  echo "Documentation generated successfully: $OUTPUT_FILE"
else
  echo "Error: Failed to generate documentation. Please check the OpenAPI file and swagger-cli installation."
  exit 1
fi

