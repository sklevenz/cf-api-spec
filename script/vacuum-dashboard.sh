#!/usr/bin/env bash

vacuum dashboard gen/openapi.yaml --ruleset cfg/vacuum-ruleset.yaml --ignore-file cfg/vacuum-ignore.yaml --watch
