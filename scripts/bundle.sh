#!/usr/bin/env bash

# Bash script to bundle an OpenAPI specification file using Redocly

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Define the input and output file paths
INPUT_SPEC="spec/openapi.yaml"
OUTPUT_SPEC="./gen/openapi.yaml"

# Check if the input file exists
if [ ! -f "$INPUT_SPEC" ]; then
  echo "Error: Input file '$INPUT_SPEC' does not exist."
  exit 1
fi

# Ensure the output directory exists
OUTPUT_DIR=$(dirname "$OUTPUT_SPEC")
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
  echo "Created output directory '$OUTPUT_DIR'."
fi

# Run the Redocly bundle command
redocly bundle "$INPUT_SPEC" -o "$OUTPUT_SPEC"

# Capture the exit status of the command
EXIT_STATUS=$?

# Check if the command was successful
if [ $EXIT_STATUS -eq 0 ]; then
  echo "Bundling completed successfully. Output file: $OUTPUT_SPEC"
else
  echo "Bundling failed. Please check the output for details."
fi

# Exit with the command's status code
exit $EXIT_STATUS