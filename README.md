# cf-api-spec

OpenAPI Specification of the Cloud Foundry API

[![Lint Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/lint.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Bundle Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/bundle.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Test Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/test.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
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

The following tools are required in your Bash environment.

### Core Requirements (most workflows)
- `bash`
- `make`
- `node` (Node.js)
- `npm`
- `npx`

### Additional Requirements for Release Workflows
- `gh` (GitHub CLI)
- `git`
- `jq`
- `yq` (YAML processor)

### Additional Requirements for Documentation Workflows
- `wget`

### Additional Requirements for Mock and Test Workflows
- `curl`
- `cf` (Cloud Foundry CLI)
- `yq`

---

## Usage

All workflows are executed via the Makefile. Run `make help` to see the complete list of available targets.

---

### General

Installs the required tools, bundles the specification, runs validation, and generates documentation in a single workflow.

---

### Linting

Validates the OpenAPI specification using Vacuum.

Linting can be executed against both the modular source specification and the bundled specification, with optional hard mode enforcement.

Vacuum uses a custom ruleset and an ignore file located in the `./cfg` directory to control validation behavior and rule suppression.

In hard mode, all rule violations are treated as errors; in practice, this mode is intentionally strict and rarely fully satisfied by real world specifications.

---

### Bundling and Splitting

Bundles the modular OpenAPI specification into a single flattened file located in `./gen/openapi.yaml`.

Provides alternative bundling implementations and allows splitting a bundled specification back into the modular structure under `./spec`.

Together with the interactive dashboards, this forms the typical development workflow:

- Edit the modular specification in `./spec` while running a dashboard in a separate terminal for immediate validation feedback
- Alternatively, edit the bundled file (`./gen/openapi.yaml`) and split it back into the modular structure afterwards

This combination of dashboards, bundling, and splitting enables an efficient iterative development mode for refining and restructuring the specification.

---

### Documentation

Generates static HTML documentation from the OpenAPI specification and writes the result to `./docs/index.html`.

A GitHub Pages workflow publishes this documentation automatically from the `main` branch to:

https://sklevenz.github.io/cf-api-spec

---

### Mock

Creates a merged specification of the Cloud Foundry API and the UAA mock specification, writes it to `./gen/openapi-mock.yaml`, and starts a local Prism mock server.

The mock works by joining the main CF OpenAPI specification (`./spec/openapi.yaml`) with the dedicated UAA mock specification (`./mock/uaa.yaml`). The merged result is written to `./gen/openapi-mock.yaml` and served by Prism on `http://localhost:4010`.

Because UAA endpoints are part of the merged specification, authentication flows can be simulated locally. The mock does not perform real credential validation.

Example CF CLI command sequence:

1. `cf api http://localhost:4010`
2. `cf auth username password`  
   (The mock does not validate credentials)
3. `cf target -o org -s space`

The CF CLI maintains the session under `$HOME/.cf/config.json`.

4. `cf orgs`
5. `cf curl /v3/apps`

This enables end to end interaction testing against mocked CF and UAA APIs without running a real Cloud Foundry deployment.

The OpenAPI specification contains curated example responses that are used by the mock server. These examples can be extended at any time to refine or enrich the mocked behavior.

---

### Dashboards

Starts the interactive Vacuum dashboard for exploring linting results, rules, and validation feedback for both source and bundled specifications.

The dashboards are typically used in parallel with bundling and splitting during development:

- Run a dashboard while editing the modular specification in `./spec` to receive immediate rule feedback
- Run a dashboard against the bundled specification (`./gen/openapi.yaml`) to validate the flattened result

This makes the dashboard the central feedback loop in the iterative development mode of the specification.

The dashboard can also be started in hard mode; however, similar to linting hard mode, this configuration is intentionally strict and primarily useful for theoretical rule evaluation rather than practical day to day development.

---

### Maintenance

Installs or updates required CLI tools locally and maintains the linting configuration.

Linting rules are defined in:

- `./cfg/vacuum-ruleset.yaml`
- `./cfg/vacuum-ignore.yaml`

The ignore file is generated from Vacuum hard mode once the specification quality is considered acceptable.

Typical workflow:

1. Generate ignore file from hard mode
2. Review the generated ignore file
3. Remove ignored rules that should not be accepted
4. Fix the specification accordingly (while having a vacuum dashboard open in parallel)
5. Repeat until the linter passes as expected

---

### Releasing

Creates GitHub releases including generated artifacts and provides visibility into existing releases.

````
Releasing:
  make release               - Create a release on github
  make release-list          - List available releases
  make next-version          - Set next version in openapi.yaml (+ manual commit)
````

---

# References

- https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html
- https://sklevenz.github.io/cf-api-spec

