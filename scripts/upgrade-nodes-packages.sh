#!/usr/bin/env bash

# Enable warnings suppression for Node.js
export NODE_NO_WARNINGS=1

# Update npm itself
echo "Updating npm to the latest version..."
npm install -g npm || { echo "Failed to update npm"; exit 1; }

# Update all globally installed packages
echo "Updating all locally installed npm packages..."
npm -g update || { echo "Failed to update global npm packages"; exit 1; }

# Define packages to update
packages=(
  "@stoplight/spectral-cli"
  "@apidevtools/swagger-cli"
  "@redocly/cli"
)

# Install or update packages
for package in "${packages[@]}"; do
  echo "Installing or updating $package..."
  npm install -g "$package" || { echo "Failed to install/update $package"; exit 1; }
done

echo "All packages have been successfully updated!"