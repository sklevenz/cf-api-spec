#!/usr/bin/env bash

# Bash script to build OpenAPI documentation using Redocly

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Define the input specification file and output file path
INPUT_SPEC="./spec/openapi.yaml"
OUTPUT_DOC="./docs/index.html"

# Check if the input file exists
if [ ! -f "$INPUT_SPEC" ]; then
  echo "Error: Input file '$INPUT_SPEC' does not exist."
  exit 1
fi

# Ensure the output directory exists
OUTPUT_DIR=$(dirname "$OUTPUT_DOC")
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
  echo "Created output directory '$OUTPUT_DIR'."
fi

# Run the Redocly build-docs command
redocly build-docs "$INPUT_SPEC" -o "$OUTPUT_DOC"

# Capture the exit status of the command
EXIT_STATUS=$?

# Check if the command was successful
if [ $EXIT_STATUS -eq 0 ]; then
  echo "Documentation built successfully. Output file: $OUTPUT_DOC"
else
  echo "Documentation build failed. Please check the output for details."
fi

# Exit with the command's status code
exit $EXIT_STATUS