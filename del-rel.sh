#!/usr/bin/env bash
gh release delete test-0.0.0 --yes
git push origin --delete tag test-0.0.0