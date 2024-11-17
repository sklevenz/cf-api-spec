#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Set variables
SPEC_FILE="spec/openapi.yaml"
OUTPUT_DIR="docs"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

# Check if redocly/cli is installed
if ! command -v redocly &> /dev/null; then
  echo "Error: redocly/cliis not installed. Please install it with 'npm install -g @redocly/cli'."
  exit 1
fi

# Ensure the spec file exists
if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: Spec file '$SPEC_FILE' does not exist. Please provide a valid OpenAPI file."
  exit 1
fi

# Create the output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Output directory '$OUTPUT_DIR' does not exist. Creating it..."
  mkdir -p "$OUTPUT_DIR"
fi

# Generate the documentation
echo "Generating API documentation from '$SPEC_FILE' to '$OUTPUT_FILE'..."
npx @redocly/cli build-docs "$SPEC_FILE" --output "$OUTPUT_FILE"

# Check if the generation was successful
if [ $? -eq 0 ]; then
  echo "Documentation generated successfully: $OUTPUT_FILE"
else
  echo "Error: Failed to generate documentation."
  exit 1
fi