SPEC_FILE := spec/openapi.yaml
SPECTRAL_RULESET := ./cfg/spectral-ruleset.yaml
OUTPUT_DOC := ./docs/index.html
OUTPUT_DIR := $(dir $(OUTPUT_DOC))
BUNDLE_OUTPUT := ./gen/openapi.yaml
BUNDLE_OUTPUT_DIR := $(dir $(BUNDLE_OUTPUT))
MOCK_SERVER_PORT := 4010

.PHONY: help all lint lint-redocly lint-vacuum lint-spectral docs bundle mock upgrade

help:
	@echo "Available targets:"
	@echo "  make all            - Install tools, bundle spec, lint, and build docs"
	@echo "  make lint           - Run both Redocly and Spectral linters"
	@echo "  make lint-redocly   - Run Redocly linter and stats"
	@echo "  make lint-vacuum    - Run Vakuum linter and stats"
	@echo "  make lint-spectral  - Run Spectral linter (optional, partial OpenAPI 3.1 support)"
	@echo "  make docs           - Generate HTML documentation using Redocly"
	@echo "  make bundle         - Bundle OpenAPI spec using Redocly"
	@echo "  make mock           - Start local mock server with Prism"
	@echo "  make upgrade        - Install CLI tools locally (CI-safe, no sudo)"
	@echo "  make help           - Show this help message"

all: upgrade lint bundle docs

upgrade:
	@echo "Installing/updating required CLI tools locally..."
	@npm install --no-save @redocly/cli @stoplight/spectral-cli @stoplight/prism-cli
	@go install github.com/daveshanley/vacuum@latest
	@echo "Installed tool versions:"
	@npx redocly --version
	@npx spectral --version
	@npx prism --version
	@vacuum version

lint: lint-redocly lint-vacuum

lint-redocly:
	@echo "Running Redocly linter..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: File '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@if npx redocly lint "$(SPEC_FILE)" --format stylish; then \
		echo "Redocly linting completed successfully. Running stats..."; \
		if npx redocly stats "$(SPEC_FILE)"; then \
			echo "Redocly stats completed successfully."; \
		else \
			echo "Redocly stats command failed. Please check the output for details."; \
		fi \
	else \
		echo "Redocly linting failed. Please check the output for details."; \
	fi

lint-vacuum:
	@echo "Running Vacuum linter..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: File '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@vacuum lint "$(SPEC_FILE)"

lint-spectral:
	@echo "Run Spectral linter (optional, partial OpenAPI 3.1 support)"
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: File '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@if npx spectral lint "$(SPEC_FILE)" --ruleset="$(SPECTRAL_RULESET)"; then \
		echo "Spectral linting completed successfully."; \
	else \
		echo "Spectral linting failed. Please check the output for details."; \
	fi

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