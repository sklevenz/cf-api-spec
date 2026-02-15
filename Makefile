
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
	@./scripts/upgrade.sh

lint:
	@./scripts/lint.sh source standard
	
lint-hard:
	@./scripts/lint.sh source hard

lint-bundle:
	@./scripts/lint.sh bundle standard

lint-bundle-hard:
	@./scripts/lint.sh bundle hard

docs:
	@./scripts/docs.sh

bundle: bundle-redocly # change to vacuum as soon as securitySchemes gets rendered correctly

bundle-vacuum:
	@./scripts/bundle-vacuum.sh

bundle-redocly:
	@./scripts/bundle-redocly.sh

split-bundle:
	@./scripts/split-bundle.sh

mock:
	@./scripts/mock.sh

dashboard:
	@./scripts/dashboard.sh source standard

dashboard-hard:
	@./scripts/dashboard.sh source hard

dashboard-bundle:
	@./scripts/dashboard.sh bundle standard

dashboard-bundle-hard:
	@./scripts/dashboard.sh bundle hard

ignore-file:
	@./scripts/ignore-file.sh

check-version:
ifndef VERSION
	$(error VERSION is required, use: make release VERSION=0.0.0)
endif

release-list: 
	@gh release list

release: check-version bundle docs
	@./scripts/release.sh