SHELL := /usr/bin/env bash

SCRIPTS_DIR := ./scripts
GEN_DIR := ./gen
DOCS_DIR := ./docs

.PHONY: \
	help all upgrade \
	lint lint-hard lint-bundle lint-bundle-hard \
	bundle bundle-vacuum bundle-redocly split-bundle \
	docs  \
	mock \
	dashboard dashboard-hard dashboard-bundle dashboard-bundle-hard \
	ignore-file \
	release release-list next-version

help:
	@echo "Available targets:"
	@echo ""
	@echo "General:"
	@echo "  make all                   - Install tools, bundle spec, lint, and build docs"
	@echo "  make help                  - Show this help message"
	@echo ""
	@echo "Linting:"
	@echo "  make lint                  - Run Vacuum linter on source spec"
	@echo "  make lint-hard             - Run Vacuum linter in hard mode on source spec"
	@echo "  make lint-bundle           - Run Vacuum linter on bundled spec (./gen/openapi.yaml)"
	@echo "  make lint-bundle-hard      - Run Vacuum linter in hard mode on bundled spec (./gen/openapi.yaml)"
	@echo ""
	@echo "Bundling and splitting:"
	@echo "  make bundle                - Bundle OpenAPI spec using Redocly"
	@echo "  make bundle-vacuum         - Bundle OpenAPI spec using Vacuum (known issues with securitySchemes)"
	@echo "  make bundle-redocly        - Bundle OpenAPI spec using Redocly"
	@echo "  make split-bundle          - Split bundled spec into file structure (./spec)"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs                  - Generate versioned HTML docs + index (./docs/index.html)"
	@echo ""
	@echo "Mock:"
	@echo "  make mock                  - Start local Prism mock server"
	@echo ""
	@echo "Dashboards:"
	@echo "  make dashboard             - Start Vacuum dashboard with custom ruleset"
	@echo "  make dashboard-hard        - Start Vacuum dashboard in hard mode"
	@echo "  make dashboard-bundle      - Start Vacuum dashboard for bundled spec"
	@echo "  make dashboard-bundle-hard - Start Vacuum dashboard in hard mode for bundled spec"
	@echo ""
	@echo "Maintenance:"
	@echo "  make upgrade               - Install or update CLI tools locally (CI safe, no sudo)"
	@echo "  make ignore-file           - Generate Vacuum ignore file from hard mode report"
	@echo ""
	@echo "Releasing:"
	@echo "  make release               - Release on github"
	@echo "  make release-list          - List available releases"
	@echo "  make next-version          - Set next version"


all: upgrade lint bundle docs2

upgrade:
	@$(SCRIPTS_DIR)/upgrade.sh

lint:
	@$(SCRIPTS_DIR)/lint.sh source standard
	
lint-hard:
	@$(SCRIPTS_DIR)/lint.sh source hard

lint-bundle:
	@$(SCRIPTS_DIR)/lint.sh bundle standard

lint-bundle-hard:
	@$(SCRIPTS_DIR)/lint.sh bundle hard

docs:
	@$(SCRIPTS_DIR)/docs.sh

bundle: bundle-redocly # TODO switch default to Vacuum once securitySchemes render correctly

bundle-vacuum:
	@$(SCRIPTS_DIR)/bundle-vacuum.sh

bundle-redocly:
	@$(SCRIPTS_DIR)/bundle-redocly.sh

split-bundle:
	@$(SCRIPTS_DIR)/split-bundle.sh

mock:
	@$(SCRIPTS_DIR)/mock.sh

dashboard:
	@$(SCRIPTS_DIR)/dashboard.sh source standard

dashboard-hard:
	@$(SCRIPTS_DIR)/dashboard.sh source hard

dashboard-bundle:
	@$(SCRIPTS_DIR)/dashboard.sh bundle standard

dashboard-bundle-hard:
	@$(SCRIPTS_DIR)/dashboard.sh bundle hard

ignore-file:
	@$(SCRIPTS_DIR)/ignore-file.sh

release-list:
	@$(SCRIPTS_DIR)/release-list.sh

release: lint bundle docs
	@$(SCRIPTS_DIR)/release.sh

next-version: release-list
	@$(SCRIPTS_DIR)/next-version.sh
