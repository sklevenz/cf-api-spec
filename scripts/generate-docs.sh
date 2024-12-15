#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Set variables
SPEC_FILE="spec/openapi.yaml"
OUTPUT_DIR="gen/docs"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

# Function to print messages
print_error() {
  echo "Error: $1"
}

print_success() {
  echo "Success: $1"
}

print_info() {
  echo "Info: $1"
}

# Check if redocly/cli is installed
if ! command -v redocly &> /dev/null; then
  print_error "redocly/cli is not installed. Please install it with 'npm install -g @redocly/cli'."
  exit 1
fi

# Ensure the spec file exists
if [ ! -f "$SPEC_FILE" ]; then
  print_error "Spec file '$SPEC_FILE' does not exist. Please provide a valid OpenAPI file."
  exit 1
fi

# Create the output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
  print_info "Output directory '$OUTPUT_DIR' does not exist. Creating it..."
  mkdir -p "$OUTPUT_DIR" || { print_error "Failed to create output directory '$OUTPUT_DIR'."; exit 1; }
fi

# Generate the documentation
print_info "Generating API documentation from '$SPEC_FILE' to '$OUTPUT_FILE'..."
npx @redocly/cli build-docs "$SPEC_FILE" --output "$OUTPUT_FILE"

# Check if the generation was successful
if [ $? -eq 0 ]; then
  print_success "Documentation generated successfully: $OUTPUT_FILE"
else
  print_error "Failed to generate documentation."
  exit 1
fi