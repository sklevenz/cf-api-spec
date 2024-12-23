# cf-api-spec

OpenAPI Specification of Cloud Foundry API

[![Lint Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/lint.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Bundle Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/bundle.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Documentation Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/docs.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)

## Abstract

This project provides an OpenAPI Specification for the [Cloud Foundry API](https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html), covering the Cloud Controller and Korifi APIs. By defining a standardized and machine-readable format, the specification aims to enhance developer productivity, improve API integration, and ensure consistent documentation.

The OpenAPI Specification was developed using a combination of tools, including Swagger for API exploration and ChatGPT for collaborative and iterative refinement of schema definitions and documentation. This approach allowed for efficient translation of Cloud Foundry’s comprehensive API documentation into a robust OpenAPI format.

The repository serves as a foundation for:

* Client and server code generation to streamline development.
* Interactive API documentation for developers.
* Enhanced validation and testing of API interactions.

Through this effort, the project contributes to the Cloud Foundry ecosystem by promoting greater accessibility, transparency, and interoperability for its APIs.

## API Documentation

https://sklevenz.github.io/cf-api-spec

## Folder Structure

The directory structure of this repository is organized to separate concerns and improve clarity. Each folder serves a specific purpose, from storing the OpenAPI specification and its components to providing tools and scripts for validation, documentation generation, and testing.


```plaintext
├── docs                # Documentation files for the project (e.g., guides, references)
├── scripts             # Utility scripts for automation, setup, or deployment
├── spec                # OpenAPI specification and its components
|   ├-- paths           # Path elements of the OpenAPI spec
│   ├── components      # Reusable elements (parameters, responses, schemas ...) for the OpenAPI spec
    └── openapi.yaml    # Main OpenAPI specification file (defines paths, operations, and components)
```
---

## Tools Used

This project utilizes the following tools for development and documentation:

### [Redoc CLI](https://github.com/Redocly/redoc)

Redoc CLI is used to generate an interactive HTML documentation page from the OpenAPI specification.

- **Installation**:
  ```bash
  npm install -g @redocly/cli
  ```

- **Usage**:
  Run the following command to generate documentation:
  ```bash
  redocly build-docs spec/openapi.yaml --output docs/index.html
  ```

### [Spectral CLI](https://github.com/stoplightio/spectral)

Spectral CLI is used to lint and validate OpenAPI specifications against predefined rulesets or custom rules.

- **Installation**:
  ```bash
  npm install -g @stoplight/spectral-cli

- **Usage**:
  Run the following command to generate documentation:
  ```bash
  spectral lint spec/openapi.yaml --ruleset ./script/cfg/spectral-ruleset.yaml
  ```

### Additional Requirements
Ensure you have Node.js installed to use `npm`. You can download it from the [official Node.js website](https://nodejs.org/).

```bash
# Verify Node.js and npm installation
node -v
npm -v
```

---

## Usage

**Upgrade Node.js Tools**:
   Use the `upgrade-nodes-packages.sh` script to update Node.js tools like `@redocly/cli` to their latest versions.

   **Usage**:
   ```bash
   bash ./scripts/upgrade-nodes-packages.sh
   ```

**Lint the OpenAPI Specification**:
   Use the `lint.sh` script to ensure the OpenAPI spec is valid:
   ```bash
   bash ./scripts/lint.sh
   ```

**Build Documentation**:
   Build interactive API documentation using the `docs.sh` script:
   ```bash
   bash ./scripts/docs.sh
   ```

   The generated documentation will be available at `docs/index.html`.

**Bundle Specificationn**:
   Generate API bundle `bundle.sh` script:
   ```bash
   bash scripts/bundle.sh
   ```

   The generated documentation will be available at `./docs/index.html`.
**View the Documentation**:
   Open the generated documentation in a browser:
   ```bash
   open ./docs/index.html
   ```

[1] https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html
[2] https://sklevenz.github.io/cf-api-spec
