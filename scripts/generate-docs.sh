#!/usr/bin/env bash

# Set variables
SPEC_FILE="spec/openapi.yaml"
OUTPUT_DIR="docs"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

# Check if redoc-cli is installed
if ! command -v redoc-cli &> /dev/null; then
  echo "Error: redoc-cli is not installed. Please install it with 'npm install -g redoc-cli'."
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
redoc-cli bundle "$SPEC_FILE" -o "$OUTPUT_FILE"

# Check if the generation was successful
if [ $? -eq 0 ]; then
  echo "Documentation generated successfully: $OUTPUT_FILE"
else
  echo "Error: Failed to generate documentation."
  exit 1
fi