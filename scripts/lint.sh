#!/usr/bin/env bash

# Bash script to lint an OpenAPI specification file using Redocly and run stats if linting succeeds

# Suppress warnings for Node.js
export NODE_NO_WARNINGS=1

# Define the OpenAPI specification file path
SPEC_FILE="spec/openapi.yaml"

# Check if the file exists
if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: File '$SPEC_FILE' does not exist."
  exit 1
fi

# Run the Redocly lint command
redocly lint "$SPEC_FILE" --format stylish

# Capture the exit status of the command
EXIT_STATUS=$?

# Check if the lint command was successful
if [ $EXIT_STATUS -eq 0 ]; then
  echo "Linting completed successfully. Running stats..."
  
  # Run the Redocly stats command
  redocly stats "$SPEC_FILE"
  
  # Capture the exit status of the stats command
  STATS_EXIT_STATUS=$?
  
  if [ $STATS_EXIT_STATUS -eq 0 ]; then
    echo "Stats completed successfully."
  else
    echo "Stats command failed. Please check the output for details."
  fi
else
  echo "Linting failed. Please check the output for details."
fi

# Exit with the lint command's status code
exit $EXIT_STATUS