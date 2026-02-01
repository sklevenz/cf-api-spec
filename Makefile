SPEC_DIR := ./spec
CFG_DIR := ./cfg
DOC_DIR := ./docs
MOCK_DIR := ./mock
GEN_DIR := ./gen
SPLIT_DIR := $(GEN_DIR)/spec

SPEC_FILE := $(SPEC_DIR)/openapi.yaml
VACUUM_RULESET := $(CFG_DIR)/vacuum-ruleset.yaml
VACUUM_IGNORE := $(CFG_DIR)/vacuum-ignore.yaml
DOC_FILE := $(DOC_DIR)/index.html
BUNDLE_FILE := $(GEN_DIR)/openapi.yaml
UAA_SPEC_FILE := $(MOCK_DIR)/uaa.yaml
MOCK_SPEC_FILE := $(GEN_DIR)/openapi-mock.yaml

MOCK_PORT := 4010

.PHONY: help all lint lint-hard lint-bundle lint-bundle-hard docs bundle release release-list \
        bundle-vacuum bundle-redocly split-bundle mock dashboard dashboard-bundle \
        dashboard-hard dashboard-bundle-hard ignore-file upgrade

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
	@echo "  make bundle                - Bundle OpenAPI spec using Vacuum"
	@echo "  make bundle-vacuum         - Bundle OpenAPI spec using Vacuum (known issues with securityScheme)"
	@echo "  make bundle-redocly        - Bundle OpenAPI spec using Redocly"
	@echo "  make split-bundle          - Split bundled spec into file structure (./spec)"
	@echo ""
	@echo "Documentation:"
	@echo "  make docs                  - Generate HTML documentation using Redocly (./docs/index.html)"
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
	@echo "  make release               - Release on github (VERSION=0.0.0)"
	@echo "  make release-list          - List available releases"


all: upgrade lint bundle docs

upgrade:
	@echo "Installing CLI tools locally"
	@npm install --no-save @redocly/cli @stoplight/prism-cli @quobix/vacuum
	@echo ""
	@echo "Installed tool versions"
	@printf "  Redocly  %s\n" "$$(npx redocly --version)"
	@printf "  Prism    %s\n" "$$(npx prism --version)"
	@printf "  Vacuum   %s\n" "$$(npx vacuum version)"
	@echo ""

lint:
	@echo "Running Vacuum linter on source spec"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@npx vacuum lint "$(SPEC_FILE)" --ruleset="$(VACUUM_RULESET)" --ignore-file "$(VACUUM_IGNORE)"
	@echo ""
	
lint-hard:
	@echo "Running Vacuum linter in hard mode on source spec"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@npx vacuum lint "$(SPEC_FILE)" --hard-mode --ignore-file "$(VACUUM_IGNORE)"
	@echo ""

lint-bundle:
	@echo "Running Vacuum linter on bundled spec"
	@if [ ! -f "$(BUNDLE_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Bundled spec not found"; \
		echo "  Path: $(BUNDLE_FILE)"; \
		exit 1; \
	fi
	@npx vacuum lint "$(BUNDLE_FILE)" --ruleset="$(VACUUM_RULESET)" --ignore-file "$(VACUUM_IGNORE)"
	@echo ""

lint-bundle-hard:
	@echo "Running Vacuum linter in hard mode on bundled spec"
	@if [ ! -f "$(BUNDLE_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Bundled spec not found"; \
		echo "  Path: $(BUNDLE_FILE)"; \
		exit 1; \
	fi
	@npx vacuum lint "$(BUNDLE_FILE)" --hard-mode --ignore-file "$(VACUUM_IGNORE)"
	@echo ""

docs:
	@echo "Building HTML documentation"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@mkdir -p "$(DOC_DIR)"
	@npx redocly build-docs "$(SPEC_FILE)" -o "$(DOC_FILE)"
	@STATUS=$$?; \
	if [ $$STATUS -eq 0 ]; then \
		echo ""; \
		echo "Documentation generated"; \
		echo "  Output: $(DOC_FILE)"; \
	else \
		echo ""; \
		echo "Documentation build failed"; \
		echo "  Please check the output above for details"; \
		exit $$STATUS; \
	fi
	@echo ""

bundle: bundle-redocly # change to vacuum as soon as securitySchemes gets rendered correctly

bundle-vacuum:
	@echo "Bundling OpenAPI specification using Vacuum"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@mkdir -p "$(GEN_DIR)"
	@npx vacuum bundle "$(SPEC_FILE)" "$(BUNDLE_FILE)" --base "$(SPEC_DIR)"
	@STATUS=$$?; \
	if [ $$STATUS -eq 0 ]; then \
		echo ""; \
		echo "Bundling completed"; \
		echo "  Output: $(BUNDLE_FILE)"; \
		echo ""; \
		echo "Warning"; \
		echo "  Vacuum does not render securitySchemes correctly"; \
		echo "  Use only if version is newer than 0.23.0"; \
	else \
		echo ""; \
		echo "Bundling failed"; \
		echo "  Please check the output above for details"; \
		exit $$STATUS; \
	fi
	@echo ""

bundle-redocly:
	@echo "Bundling OpenAPI specification using Redocly"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@mkdir -p "$(GEN_DIR)"
	@npx redocly bundle "$(SPEC_FILE)" -o "$(BUNDLE_FILE)"
	@STATUS=$$?; \
	if [ $$STATUS -eq 0 ]; then \
		echo ""; \
		echo "Bundling completed"; \
		echo "  Output: $(BUNDLE_FILE)"; \
	else \
		echo ""; \
		echo "Bundling failed"; \
		echo "  Please check the output above for details"; \
		exit $$STATUS; \
	fi
	@echo ""

split-bundle:
	@echo "Splitting bundled OpenAPI specification"
	@if [ ! -f "$(BUNDLE_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Bundled spec not found"; \
		echo "  Path: $(BUNDLE_FILE)"; \
		exit 1; \
	fi
	@rm -rf "$(SPLIT_DIR)"
	@npx redocly split "$(BUNDLE_FILE)" --outDir "$(SPLIT_DIR)"
	@STATUS=$$?; \
	if [ $$STATUS -eq 0 ]; then \
		echo ""; \
		echo "Split completed"; \
		echo "  Output directory: $(SPLIT_DIR)"; \
	else \
		echo ""; \
		echo "Split failed"; \
		echo "  Please check the output above for details"; \
		exit $$STATUS; \
	fi
	@rm -rf "$(SPEC_DIR)"
	@mv "$(SPLIT_DIR)" .
	@echo ""; \
	echo "Spec updated"; \
	echo "  Target directory: $(SPEC_DIR)"; \
	echo ""

mock:
	@echo "Starting Prism mock server"
	@mkdir -p gen
	@npx -y @redocly/cli join "$(SPEC_FILE)" "$(UAA_SPEC_FILE)" -o "$(MOCK_SPEC_FILE)"
	@npx prism mock "$(MOCK_SPEC_FILE)" --port "$(MOCK_PORT)"

dashboard:
	@echo "Starting Vacuum dashboard on source spec"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@echo "  Mode: standard"
	@echo ""
	@npx vacuum dashboard "$(SPEC_FILE)" --ruleset="$(VACUUM_RULESET)" --ignore-file "$(VACUUM_IGNORE)" --watch

dashboard-hard:
	@echo "Starting Vacuum dashboard on source spec"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@echo "  Mode: hard"
	@echo ""
	@npx vacuum dashboard "$(SPEC_FILE)" --ignore-file "$(VACUUM_IGNORE)" --hard-mode --watch

dashboard-bundle:
	@echo "Starting Vacuum dashboard on bundled spec"
	@if [ ! -f "$(BUNDLE_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Bundled spec not found"; \
		echo "  Path: $(BUNDLE_FILE)"; \
		exit 1; \
	fi
	@echo "  Mode: standard"
	@echo ""
	@npx vacuum dashboard "$(BUNDLE_FILE)" --ruleset="$(VACUUM_RULESET)" --ignore-file "$(VACUUM_IGNORE)" --watch

dashboard-bundle-hard:
	@echo "Starting Vacuum dashboard on bundled spec"
	@if [ ! -f "$(BUNDLE_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Bundled spec not found"; \
		echo "  Path: $(BUNDLE_FILE)"; \
		exit 1; \
	fi
	@echo "  Mode: hard"
	@echo ""
	@npx vacuum dashboard "$(BUNDLE_FILE)" --ignore-file "$(VACUUM_IGNORE)" --hard-mode --watch

ignore-file:
	@echo "Generating Vacuum ignore file for $(SPEC_FILE)"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo ""; \
		echo "Error"; \
		echo "  Spec file not found"; \
		echo "  Path: $(SPEC_FILE)"; \
		exit 1; \
	fi
	@echo ""
	@tmp=$$(mktemp); \
	trap 'rm -f "$$tmp"' EXIT; \
	npx vacuum report "$(SPEC_FILE)" --stdout --hard-mode > "$$tmp"; \
	npx vacuum generate-ignorefile "$$tmp" "$(VACUUM_IGNORE)"
	@echo ""; \
	echo "Ignore file generated"; \
	echo "  Output: $(VACUUM_IGNORE)"; \
	echo ""

check-version:
ifndef VERSION
	$(error VERSION is required, use: make release VERSION=0.0.0)
endif

release-list: 
	@gh release list

release: check-version

release: check-version bundle docs
	@set -euo pipefail; \
	tag="$(VERSION)"; \
	openapi_src="$(BUNDLE_FILE)"; \
	docs_src="$(DOC_FILE)"; \
	if [[ ! -f "$$openapi_src" ]]; then echo "Error: bundled spec not found at $$openapi_src"; exit 1; fi; \
	if [[ ! -f "$$docs_src" ]]; then echo "Error: docs not found at $$docs_src"; exit 1; fi; \
	openapi_out="$(GEN_DIR)/cf-api-openapi-$$tag.yaml"; \
	docs_out="$(GEN_DIR)/cf-api-openapi-$$tag.html"; \
	cp "$$openapi_src" "$$openapi_out"; \
	cp "$$docs_src" "$$docs_out"; \
	echo "Creating GitHub release $$tag"; \
	gh release create "$$tag" "$$openapi_out" "$$docs_out" \
		--title "$$tag" \
		--target main \
		--latest \
		--generate-notes
	