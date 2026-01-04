#!/usr/bin/env bash

if [ ! -f gen/openapi.yaml ]; then
  echo "ERROR OpenAPI spec file gen/openapi.yaml not found"
  exit 1
fi

vacuum report gen/openapi.yaml -z > gen/report.yaml
vacuum generate-ignorefile gen/report.yaml cfg/vacuum-ignore.yaml
rm gen/report.yaml