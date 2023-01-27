#!/usr/bin/env bash

# Define default values for environment variables
ORG=${ORG:-"my-org"}
REPO=${REPO:-"my-repo"}
APP_NAME=${APP_NAME:-"my-app"}
BUILD_DIR=${BUILD_DIR:-"_build"}

# Check if Nix is installed
if ! [ -x "$(command -v nix-build)" ]; then
  echo "Error: nix-build is not installed. Please install Nix and try again."
  exit 1
fi

# Build with Nix
nix-build -A ${APP_NAME}

# Create release
MIX_ENV=prod mix release --verbose

# Move the release to the build directory
mkdir -p ${BUILD_DIR}
mv _build/${MIX_ENV}/${APP_NAME}-* ${BUILD_DIR}

# Build the Docker image
docker build -t ${ORG}/${REPO}:latest .

# Push the Docker image to the registry
docker push ${ORG}/${REPO}:latest
