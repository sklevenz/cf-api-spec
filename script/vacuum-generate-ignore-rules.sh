#!/usr/bin/env bash

make bundle
vacuum report gen/openapi.yaml -o > gen/report.yaml -z
vacuum generate-ignorefile gen/report.yaml cfg/vacuum-ignore.yaml
rm gen/report.yaml