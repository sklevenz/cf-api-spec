#!/usr/bin/env bash

vacuum report gen/openapi.yaml -o > gen/report.yaml -z
vacuum generate-ignorefile gen/report.yaml gen/ignore.yaml
