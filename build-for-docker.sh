#!/bin/bash
# Build script for FreeSO server to prepare for Docker deployment

set -e  # Exit on any error

echo "Building FreeSO server for Docker deployment..."

# Navigate to the server core project
cd TSOClient/FSO.Server.Core

# Restore packages with warnings not treated as errors
echo "Restoring packages..."
dotnet restore -p:WarningsNotAsErrors=NU1605

# Build the project
echo "Building the project..."
dotnet build --configuration Release -p:WarningsNotAsErrors=NU1605

# Create publish directory and copy build output
echo "Copying build output to publish directory..."
mkdir -p ../../publish
cp -r bin/Release/net9.0/* ../../publish/

echo "Build completed successfully!"
echo "Built files are in the /publish directory"
echo "You can now build the Docker image with: docker build -f Dockerfile.prod -t freesoserver:prod ."