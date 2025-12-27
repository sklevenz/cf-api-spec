SPEC_FILE := spec/openapi.yaml
VACUUM_RULESET := ./cfg/vacuum-ruleset.yaml
VACUUM_IGNORE := ./cfg/vacuum-ignore.yaml
OUTPUT_DOC := ./docs/index.html
OUTPUT_DIR := $(dir $(OUTPUT_DOC))
BUNDLE_OUTPUT := ./gen/openapi.yaml
BUNDLE_OUTPUT_DIR := $(dir $(BUNDLE_OUTPUT))
MOCK_SERVER_PORT := 4010

.PHONY: help all lint lint-vacuum docs bundle mock upgrade

help:
	@echo "Available targets:"
	@echo "  make all            - Install tools, bundle spec, lint, and build docs"
	@echo "  make lint           - Run all linters"
	@echo "  make lint-vacuum    - Run Vakuum linter and stats"
	@echo "  make docs           - Generate HTML documentation using Redocly"
	@echo "  make bundle         - Bundle OpenAPI spec using Redocly"
	@echo "  make mock           - Start local mock server with Prism"
	@echo "  make upgrade        - Install CLI tools locally (CI-safe, no sudo)"
	@echo "  make help           - Show this help message"

all: upgrade lint bundle docs

upgrade:
	@echo "Installing/updating required CLI tools locally..."
	@npm install --no-save @redocly/cli @stoplight/prism-cli @quobix/vacuum
	@echo "Installed tool versions:"
	@npx redocly --version
	@npx prism --version
	@npx vacuum version

lint: lint-vacuum

lint-vacuum:
	@echo "Running Vacuum linter..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: File '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@npx vacuum lint "$(SPEC_FILE)" --ruleset="$(VACUUM_RULESET)" --ignore-file "$(VACUUM_IGNORE)"

docs:
	@echo "Building documentation..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: Input file '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@mkdir -p "$(OUTPUT_DIR)"
	@npx redocly build-docs "$(SPEC_FILE)" -o "$(OUTPUT_DOC)"
	@STATUS=$$?; \
	if [ $$STATUS -eq 0 ]; then \
		echo "Documentation built successfully. Output file: $(OUTPUT_DOC)"; \
	else \
		echo "Documentation build failed. Please check the output for details."; \
		exit $$STATUS; \
	fi

bundle:
	@echo "Bundling OpenAPI spec..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: Input file '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@mkdir -p "$(BUNDLE_OUTPUT_DIR)"
	@npx redocly bundle "$(SPEC_FILE)" -o "$(BUNDLE_OUTPUT)"
	@STATUS=$$?; \
	if [ $$STATUS -eq 0 ]; then \
		echo "Bundling completed successfully. Output file: $(BUNDLE_OUTPUT)"; \
	else \
		echo "Bundling failed. Please check the output for details."; \
		exit $$STATUS; \
	fi

mock:
	@echo "Starting Prism mock server on port $(MOCK_SERVER_PORT)..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: Input file '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@npx prism mock "$(SPEC_FILE)" --port $(MOCK_SERVER_PORT)