SPEC_FILE := spec/openapi.yaml
SPECTRAL_RULESET := ./cfg/spectral-ruleset.yaml
OUTPUT_DOC := ./docs/index.html
OUTPUT_DIR := $(dir $(OUTPUT_DOC))
BUNDLE_OUTPUT := ./gen/openapi.yaml
BUNDLE_OUTPUT_DIR := $(dir $(BUNDLE_OUTPUT))
MOCK_SERVER_PORT := 4010

.PHONY: help all lint lint-redocly lint-spectral docs bundle mock upgrade-packages


help:
	@echo "Available targets:"
	@echo "  make all               - Upgrade tools, bundle spec, lint, and build docs"
	@echo "  make lint              - Run both Redocly and Spectral linters"
	@echo "  make lint-redocly      - Run Redocly linter and stats"
	@echo "  make lint-spectral     - Run Spectral linter"
	@echo "  make docs              - Generate HTML documentation using Redocly"
	@echo "  make bundle            - Bundle OpenAPI spec using Redocly"
	@echo "  make mock              - Start local mock server with Prism"
	@echo "  make upgrade-packages  - Upgrade npm and globally used OpenAPI CLI tools"
	@echo "  make help              - Show this help message"


lint: lint-redocly lint-spectral

lint-redocly:
	@echo "Running Redocly linter..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: File '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@if redocly lint "$(SPEC_FILE)" --format stylish; then \
		echo "Redocly linting completed successfully. Running stats..."; \
		if redocly stats "$(SPEC_FILE)"; then \
			echo "Redocly stats completed successfully."; \
		else \
			echo "Redocly stats command failed. Please check the output for details."; \
		fi \
	else \
		echo "Redocly linting failed. Please check the output for details."; \
	fi

lint-spectral:
	@echo "Running Spectral linter..."
	@if [ ! -f "$(SPEC_FILE)" ]; then \
		echo "Error: File '$(SPEC_FILE)' does not exist."; \
		exit 1; \
	fi
	@if spectral lint "$(SPEC_FILE)" --ruleset="$(SPECTRAL_RULESET)"; then \
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
	@redocly build-docs "$(SPEC_FILE)" -o "$(OUTPUT_DOC)"
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
	@redocly bundle "$(SPEC_FILE)" -o "$(BUNDLE_OUTPUT)"
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
	@prism mock "$(SPEC_FILE)" --port $(MOCK_SERVER_PORT)

upgrade-packages:
	@echo "Upgrading npm and OpenAPI CLI tools..."
	@npm install -g npm || { echo "Failed to update npm"; exit 1; }
	@npm -g update || { echo "Failed to update global npm packages"; exit 1; }
	@for pkg in @redocly/cli @stoplight/spectral-cli @stoplight/prism-cli; do \
		echo "Installing or updating $$pkg..."; \
		npm install -g $$pkg || { echo "Failed to install/update $$pkg"; exit 1; }; \
	done
	@echo "All packages have been successfully updated!"

all: upgrade-packages lint bundle docs