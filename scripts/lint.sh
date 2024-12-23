#!/usr/bin/env bash

# Bash script to lint an OpenAPI specification file using Redocly or Spectral linters

# Suppress warnings for Node.js
export NODE_NO_WARNINGS=1

# Define the OpenAPI specification file path
SPEC_FILE="spec/openapi.yaml"
SPECTRAL_RULESET="./scripts/cfg/spectral-ruleset.yaml"

# Check if the file exists
if [ ! -f "$SPEC_FILE" ]; then
  echo "Error: File '$SPEC_FILE' does not exist."
  exit 1
fi

# Parse the parameter for linter choice
LINTER=${1:-both}

# Function to run Redocly linter and stats
run_redocly() {
  echo "Running Redocly linter..."
  redocly lint "$SPEC_FILE" --format stylish
  REDOCLY_EXIT_STATUS=$?

  if [ $REDOCLY_EXIT_STATUS -eq 0 ]; then
    echo "Redocly linting completed successfully. Running stats..."
    redocly stats "$SPEC_FILE"
    STATS_EXIT_STATUS=$?
    
    if [ $STATS_EXIT_STATUS -eq 0 ]; then
      echo "Redocly stats completed successfully."
    else
      echo "Redocly stats command failed. Please check the output for details."
    fi
  else
    echo "Redocly linting failed. Please check the output for details."
  fi
}

# Function to run Spectral linter
run_spectral() {
  echo "Running Spectral linter..."
  spectral lint "$SPEC_FILE" --ruleset="$SPECTRAL_RULESET"
  SPECTRAL_EXIT_STATUS=$?

  if [ $SPECTRAL_EXIT_STATUS -eq 0 ]; then
    echo "Spectral linting completed successfully."
  else
    echo "Spectral linting failed. Please check the output for details."
  fi
}

# Execute based on the chosen linter
case $LINTER in
  redocly)
    run_redocly
    ;;
  spectral)
    run_spectral
    ;;
  both)
    run_redocly
    run_spectral
    ;;
  *)
    echo "Error: Invalid parameter '$LINTER'. Use 'redocly', 'spectral', or omit for both."
    exit 1
    ;;
esac