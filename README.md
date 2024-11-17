# cf-api-spec

OpenAPI Specification of Cloud Foundry API

[![Validation Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/validate-spec.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Lint Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/lint-spec.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)

## Abstract

This project provides an OpenAPI Specification for the [Cloud Foundry API](https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html), covering the Cloud Controller and Korifi APIs. By defining a standardized and machine-readable format, the specification aims to enhance developer productivity, improve API integration, and ensure consistent documentation.

The OpenAPI Specification was developed using a combination of tools, including Swagger for API exploration and ChatGPT for collaborative and iterative refinement of schema definitions and documentation. This approach allowed for efficient translation of Cloud Foundry’s comprehensive API documentation into a robust OpenAPI format.

The repository serves as a foundation for:

* Client and server code generation to streamline development.
* Interactive API documentation for developers.
* Enhanced validation and testing of API interactions.

Through this effort, the project contributes to the Cloud Foundry ecosystem by promoting greater accessibility, transparency, and interoperability for its APIs.

## Folder Structure

The directory structure of this repository is organized to separate concerns and improve clarity. Each folder serves a specific purpose, from storing the OpenAPI specification and its components to providing tools and scripts for validation, documentation generation, and testing.


```plaintext
├── docs                # Documentation files for the project (e.g., guides, references)
├── scripts             # Utility scripts for automation, setup, or deployment
├── spec                # OpenAPI specification and its components
│   ├── components      # Reusable elements for the OpenAPI spec
│   │   ├── examples    # Example data for API requests/responses
│   │   ├── parameters  # Reusable parameter definitions (e.g., query strings, headers)
│   │   ├── responses   # Reusable response definitions (e.g., 200 OK, 404 Not Found)
│   │   └── schemas     # Data model definitions (e.g., JSON objects)
│   └── openapi.yaml    # Main OpenAPI specification file (defines paths, operations, and components)
└── tests               # Test scripts/files for API validation (functionality, integration, etc.)
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
  npx @redocly/cli build-docs spec/openapi.yaml --output docs/index.html
  ```

---

### [Swagger CLI](https://github.com/APIDevTools/swagger-cli)
Swagger CLI is used for validating the OpenAPI specification to ensure it adheres to the standard.

- **Installation**:
  ```bash
  npm install -g @apidevtools/swagger-cli
  ```

- **Usage**:
  Run the following command to validate your OpenAPI spec:
  ```bash
  swagger-cli validate spec/openapi.yaml
  ```

### 3. [Spectral CLI](https://meta.stoplight.io/docs/spectral)
Spectral is a flexible linter for JSON/YAML files, designed to enforce best practices and validate OpenAPI specifications. It ensures your OpenAPI spec adheres to the standard and best practices.

- **Installation**:
  Install Spectral globally via npm:
  ```bash
  npm install -g @stoplight/spectral-cli
  ```

- **Usage**:
  ```bash
  spectral lint --ruleset script/cfg/spectral-ruleset.yaml spec/openapi.yaml
  ```
---

### Additional Requirements
Ensure you have Node.js installed to use `npm`. You can download it from the [official Node.js website](https://nodejs.org/).

```bash
# Verify Node.js and npm installation
node -v
npm -v
```

---

## Usage

**Validate the OpenAPI Specification**:
   Use the `validate.sh` script to ensure the OpenAPI spec is valid:
   ```bash
   bash scripts/validate.sh
   ```

**Lint the OpenAPI Specification**:
   Use the `lint.sh` script to ensure the OpenAPI spec is valid:
   ```bash
   bash scripts/lint.sh
   ```

**Generate Documentation**:
   Generate interactive API documentation using the `generate-docs.sh` script:
   ```bash
   bash scripts/generate-docs.sh
   ```

   The generated documentation will be available at `docs/index.html`.

**View the Documentation**:
   Open the generated documentation in a browser:
   ```bash
   open docs/index.html
   ```




[1] https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html