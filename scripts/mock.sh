#!/usr/bin/env bash

# Bash script to start a Prism mock server using an OpenAPI specification file

# Define the input specification file path
INPUT_SPEC="spec/openapi.yaml"
MOCK_SERVER_PORT=4010

# Check if the input file exists
if [ ! -f "$INPUT_SPEC" ]; then
  echo "Error: Input file '$INPUT_SPEC' does not exist."
  exit 1
fi

# Start the Prism mock server
echo "Starting Prism mock server on port $MOCK_SERVER_PORT..."
prism mock "$INPUT_SPEC" --port "$MOCK_SERVER_PORT"

# Capture the exit status of the command
EXIT_STATUS=$?

# Check if the server started successfully
if [ $EXIT_STATUS -eq 0 ]; then
  echo "Prism mock server is running on http://localhost:$MOCK_SERVER_PORT"
else
  echo "Failed to start Prism mock server. Please check the output for details."
fi

# Exit with the command's status code
exit $EXIT_STATUS