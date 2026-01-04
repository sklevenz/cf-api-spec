# cf-api-spec

OpenAPI Specification of Cloud Foundry API

[![Lint Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/lint.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Bundle Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/bundle.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Documentation Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/docs.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)

## Abstract

This project provides an OpenAPI Specification for the Cloud Foundry API, covering the Cloud Controller APIs. By defining a standardized and machine readable format, the specification aims to improve developer productivity, simplify API integration, and ensure consistent and reliable documentation.

The OpenAPI Specification is developed and maintained using a streamlined toolchain, with the Makefile acting as the single entry point for all workflows. The setup focuses on a small set of purpose built tools to reduce complexity and improve maintainability.

Vacuum is used as the primary tool for OpenAPI validation, linting, reporting, and rule enforcement. Due to known limitations and occasional bugs in Vacuum, Redocly CLI is used as a fallback for selected tasks such as bundling and documentation generation. Prance is used to run a local mock server based on the specification. Spectral is no longer part of the toolchain and is not required.

All tasks such as tool installation, validation, reporting, bundling, documentation generation, and mock server startup are executed via Makefile targets to ensure reproducible and automated development workflows.

The repository serves as a foundation for:

* Client and server code generation
* Interactive API documentation
* Improved validation and testing of API interactions

Through this effort, the project contributes to the Cloud Foundry ecosystem by promoting accessibility, transparency, and interoperability of its APIs.

## API Documentation

https://sklevenz.github.io/cf-api-spec

## Folder Structure

The directory structure of this repository is organized to separate concerns and improve clarity. Each folder serves a specific purpose, from storing the OpenAPI specification and its components to configuration and workflows.

```plaintext
├── .github             # GitHub Actions workflows
│   └── workflows       # CI pipelines, lint, bundle, docs
├── cfg                 # Tool configuration, rulesets, ignore files
├── script              # Helper scripts used by Makefile targets
├── spec                # OpenAPI specification and modularized content
│   ├── openapi.yaml    # Main OpenAPI entry file
│   ├── paths           # Path items split into separate files
│   └── components      # Reusable OpenAPI components
│       ├── schemas     # Data models
│       ├── parameters  # Reusable parameters
│       ├── responses   # Reusable responses
│       ├── requestBodies  # Reusable request bodies
│       ├── examples    # Reusable examples
│       ├── headers     # Reusable headers
│       ├── links       # Reusable links
│       └── securitySchemes  # Auth definitions
├── Makefile            # Single entry point for workflows
├── README.md           # Project overview and usage
└── LICENSE             # License
````

## Tools Used

This project uses a small and well defined OpenAPI toolchain. All tools are installed automatically in their latest versions via npm and executed through a local Node.js environment using npx. The Makefile is the single entry point and guarantees deterministic behavior across local development and GitHub Actions.

The `make upgrade` target updates all required tools and creates a local Node.js environment under `./node_modules`. This ensures that every Makefile execution uses the same locally managed tool versions, independent of any globally installed tooling.

For convenience, the tools can also be installed globally or via Homebrew for ad hoc local usage, following the recommendations of each tool. This is optional and not required for the Makefile driven workflows.

### Vacuum

Vacuum is the primary tool for OpenAPI validation, linting, reporting, and rule enforcement. It is the default validator used in CI and local development.

Vacuum is executed via npx to ensure a consistent version:

```bash
@npx vacuum version
````

### Redocly CLI

Redocly CLI is used as a fallback tool, mainly for bundling and documentation generation where Vacuum currently has known limitations.

Redocly is executed via npx as part of the Makefile workflow:

```bash
@npx redocly --version
````

### Prism CLI

Prism CLI is used to run a local mock server based on the OpenAPI specification. This allows developers to test API behavior without a running backend.

Prism is executed via npx:

```bash
@npx prism --version
````

## Tool Updates and Automation

The make upgrade target updates all Node.js based tools to their latest versions. This ensures that local development and GitHub Actions always run with a well defined and up to date toolchain.

All validation, bundling, documentation generation, and mock server tasks are executed via Makefile targets, ensuring reproducible and automated workflows.

## Requirements

Node.js and npm are required to run the toolchain:

```bash
node -v
npm -v
```

## Usage

All workflows in this repository are driven exclusively via the Makefile. The Makefile installs required tools, manages a local Node.js environment, and executes all tasks in a deterministic way. No helper scripts need to be called directly.

### Upgrade and Install Tools

Install or upgrade all required Node.js based tools to their latest versions and set up a local environment under ./node_modules by running:

```bash
make upgrade
```

This target is used both locally and in GitHub Actions to ensure consistent tool versions.

### Lint and Validate the OpenAPI Specification

Run OpenAPI validation and linting using Vacuum via:

```bash
make lint
```

### Generate Documentation

Build the interactive API documentation via:

```bash
make docs
```

The generated documentation will be available at `./docs/index.html`.

### Bundle the OpenAPI Specification

Generate a bundled OpenAPI specification via:

```bash
make bundle
```

### View Documentation Locally

Open the generated documentation in your browser at `./docs/index.html`.

### Mock Server

A local mock server can be started directly via the Makefile. This uses Prism to serve the OpenAPI specification.

#### Start the Mock Server

Start the mock server via:

```bash
make mock
````

Once started, the mock server is available at
http://localhost:4010/v3

#### Example API Call

Send a request against the mock server using curl and an Authorization header. Any token value can be used to simulate authenticated requests.

```bash
curl -X GET http://localhost:4010/v3 \
  -H "Authorization: Bearer $MOCK_ACCESS_TOKEN"
  ```

## References

* https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html
* https://sklevenz.github.io/cf-api-spec
