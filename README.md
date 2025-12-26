# cf-api-spec

OpenAPI Specification of Cloud Foundry API

[![Lint Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/lint.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Bundle Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/bundle.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)
[![Documentation Status](https://github.com/sklevenz/cf-api-spec/actions/workflows/docs.yaml/badge.svg)](https://github.com/sklevenz/cf-api-spec/actions)

## Abstract

This project provides an OpenAPI Specification for the [Cloud Foundry API](https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html), covering the Cloud Controller APIs. By defining a standardized and machine-readable format, the specification aims to enhance developer productivity, improve API integration, and ensure consistent documentation.

The OpenAPI Specification was developed using a combination of tools defined in the Makefile. The complete development workflow is driven through the Makefile as the single entry point for the project.

The toolchain includes Redocly CLI for linting, bundling, statistics, and documentation generation, Spectral CLI for rule based OpenAPI validation using a custom ruleset, and Prism CLI for running a local mock server based on the specification. All tasks such as tool installation, validation, linting, bundling, documentation generation, and mock server startup are executed consistently via Makefile targets to ensure reproducible and automated development workflows.

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
  spectral lint spec/openapi.yaml --ruleset ./script/spectral-ruleset.yaml
  ```

### [Prism CLI](https://github.com/stoplightio/prism)

The Prism CLI is a powerful tool for mocking APIs defined by OpenAPI specifications, enabling you to simulate real server behavior during development.

#### **Installation**
Install the Prism CLI globally using npm:
```bash
npm install -g @stoplight/prism-cli

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

## Mock Server

You can start the mock server using the `mock.sh` script. This script launches a Prism mock server based on your OpenAPI specification.

#### **Start the Mock Server**
Run the following command to start the mock server:
```bash
bash scripts/mock.sh
```

Once started, the mock server will be available at:
[http://localhost:4010/v3/info](http://localhost:4010/v3/info)

#### **Example API Call**
You can test the mock server with a `curl` command. For example, to send a GET request with an Authorization header:

```bash
curl -X GET http://localhost:4010/v3/info \
  -H "Authorization: Bearer MOCK_ACCESS_TOKEN"
```

Replace `MOCK_ACCESS_TOKEN` with your desired token value to simulate authenticated requests.

[1] https://v3-apidocs.cloudfoundry.org/version/3.181.0/index.html
[2] https://sklevenz.github.io/cf-api-spec
