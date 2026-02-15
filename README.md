# cf-api-spec

OpenAPI Specification of the Cloud Foundry API

[![Lint Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/lint.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Bundle Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/bundle.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Documentation Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/docs.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)

---

## Abstract

This repository provides a modular OpenAPI specification for the Cloud Foundry Cloud Controller API.

The goal is to offer a machine readable and maintainable API definition that enables:

- Client and server code generation
- Deterministic validation and linting
- Reproducible documentation builds
- Local API simulation via mock server

The specification is maintained through a minimal and focused toolchain. The Makefile acts as the single entry point for all workflows to ensure reproducible and automated development processes.

---

## Toolchain Overview

The project intentionally uses a small and clearly defined OpenAPI toolchain:

```
Makefile
   ├── Vacuum      (validation, linting, reporting, rule enforcement)
   ├── Redocly     (bundling, documentation generation, spec merging)
   └── Prism       (local mock server)
```

### Vacuum

Vacuum is the primary tool for OpenAPI validation, linting, reporting, and rule enforcement. It is the default validator used in CI and local development.

```
npx vacuum version
```

### Redocly CLI

Redocly CLI is used as a fallback tool where Vacuum currently has limitations, primarily for:

- Bundling modular specifications
- Documentation generation
- Joining multiple OpenAPI specifications

```
npx redocly --version
```

### Prism CLI

Prism is used to run a local mock server based on the OpenAPI specification.

```
npx prism --version
```

---

## Mock Server Design

For local development, the mock target merges:

- The Cloud Foundry OpenAPI specification
- A dedicated UAA OpenAPI mock specification

The merge is performed using the Redocly CLI `join` command. The resulting combined specification includes both Cloud Foundry and selected UAA endpoints.

This allows the local mock server to simulate:

- CF API endpoints
- OAuth and authentication related UAA endpoints

All served through a single Prism instance.

---

## Folder Structure

The repository structure separates concerns clearly and keeps the OpenAPI specification modular and maintainable.

```plaintext
├── .github             # GitHub Actions workflows
│   └── workflows       # CI pipelines: lint, bundle, docs
├── cfg                 # Tool configuration, rulesets, ignore files
├── spec                # OpenAPI specification and modularized content
│   ├── openapi.yaml    # Main OpenAPI entry file
│   ├── paths           # Path items split into separate files
│   └── components      # Reusable OpenAPI components
│       ├── schemas
│       ├── parameters
│       ├── responses
│       ├── requestBodies
│       ├── examples
│       ├── headers
│       ├── links
│       └── securitySchemes
├── scripts             # Bash helper scripts used internally by the Makefile
├── mock                # UAA mock OpenAPI spec used for spec joining
├── Makefile            # Single entry point for all workflows
├── README.md
└── LICENSE
```

---

## Installation and Requirements

Node.js and npm are required:

```
node -v
npm -v
```

All tools are installed locally under `./node_modules` using:

```
make upgrade
```

This guarantees consistent tool versions independent of globally installed binaries.

---

## Usage

All workflows are executed exclusively through the Makefile.

### Install or Upgrade Toolchain

```
make upgrade
```

This target installs or updates the required CLI tools locally using npm without modifying `package.json`.

It installs:

- `@redocly/cli`
- `@stoplight/prism-cli`
- `@quobix/vacuum`

After installation, it prints the installed tool versions to ensure transparency and reproducibility.

### Lint the OpenAPI Specification

```
make lint
```

This target runs the Vacuum linter against the OpenAPI specification.

By default, it validates the modular source specification (`spec/openapi.yaml`) using the configured ruleset and ignore file.

Variants:

- `make lint-hard` enables Vacuum hard mode
- `make lint-bundle` lints the bundled specification (`./gen/openapi.yaml`)
- `make lint-bundle-hard` combines bundle scope with hard mode

### Generate HTML Documentation

```
make docs
```

This target generates static HTML documentation from the modular OpenAPI specification using the Redocly CLI.

It builds a self contained documentation page and writes the result to:

`./docs/index.html`

Output: `./docs/index.html`

### Bundle the Specification

```
make bundle
```

This target bundles the modular OpenAPI specification into a single self contained file using the Redocly CLI.

Internally it performs the following steps:

- Executes `redocly bundle` to resolve and inline all `$ref` references

The resulting bundled specification is written to:

`./gen/openapi.yaml`

The bundled artifact can be used for:

- Client and server code generation
- Distribution as a single OpenAPI file
- Release packaging
- Downstream tooling that requires a flattened specification


### Start the Local Mock Server

```
make mock
```

This target starts a local Prism mock server based on a merged specification.

It:

- Joins the Cloud Foundry spec and the UAA mock spec using `redocly join`
- Writes the merged file to `./gen/openapi-mock.yaml`
- Starts `prism mock` on port `4010`

The server exposes both CF API endpoints and selected UAA authentication endpoints.

http://localhost:4010/

Example:

```
curl -X GET http://localhost:4010/v3 \
  -H "Authorization: Bearer $MOCK_ACCESS_TOKEN"
```

---

## API Documentation

<https://sklevenz.github.io/cf-api-spec>

---

## References

- https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html
- https://sklevenz.github.io/cf-api-spec

