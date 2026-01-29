# FreeSO Docker Directory

This directory contains all Docker-related files for the FreeSO server deployment.

## Files Overview

- `Dockerfile.prod` - Production-ready Dockerfile for building the FreeSO server
- `docker-compose.yml` - Development Docker Compose configuration
- `docker-compose.prod.yml` - Production Docker Compose configuration
- `build-for-docker.sh` - Script to build the FreeSO application for Docker deployment
- `setup-config.sh` - Script to generate configuration files
- `deploy-prod.sh` - Production deployment script
- `monitor.sh` - Server monitoring script
- `backup.sh` - Backup automation script
- `README.md` - This documentation file

## Usage

### Quick Start (Recommended for New Users)
For a completely automated setup that handles everything from building to deployment:
```bash
chmod +x quick-start-docker.sh
./quick-start-docker.sh
```

This script will:
- Check all prerequisites
- Validate the presence of required TSO game files
- Build the FreeSO application
- Generate configuration files
- Create necessary secrets
- Set up environment variables
- Start the Docker services
- Verify that everything is running correctly

### For Development:
```bash
docker-compose up -d
```

### For Production:
```bash
# Build the application
chmod +x build-for-docker.sh
./build-for-docker.sh

# Configure the server (choose one approach)
# Option 1: Automated setup (recommended)
chmod +x setup-config.sh
./setup-config.sh

# Option 2: Manual configuration
cp ../TSOClient/FSO.Server/config.sample.json config.json
# Edit config.json to match your production settings

# Deploy with production compose
docker-compose -f docker-compose.prod.yml up -d
```

### Quick Start Script Features
The `quick-start-docker.sh` script provides:
- Prerequisite checking (Docker, .NET SDK, etc.)
- Automatic application building
- Configuration generation with sensible defaults
- Secure secret generation
- Environment setup
- Service startup and validation
- Status reporting throughout the process

## Important Notes

- All Docker-related files have been consolidated in this directory for better organization
- The main documentation files have been updated to reference these correct paths
- Scripts should be run from the project root directory (one level up from this directory)
- Configuration files should still be placed in the project root as the Docker volumes mount from there