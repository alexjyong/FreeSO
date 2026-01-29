# FreeSO Docker Deployment

This directory contains Docker configuration files for deploying the FreeSO server in containerized environments.

## Files Overview

- `Dockerfile` - Development Dockerfile that attempts to build from source
- `Dockerfile.prod` - Production-ready Dockerfile for pre-built binaries
- `docker-compose.yml` - Development compose file
- `docker-compose.prod.yml` - Production compose file with security enhancements
- `build-for-docker.sh` - Script to build the application for Docker deployment
- `DOCKER_SETUP.md` - Complete setup and deployment documentation

## Quick Start

### For Development:
```bash
docker-compose up -d
```

### For Production:
1. Build the application:
   ```bash
   chmod +x build-for-docker.sh
   ./build-for-docker.sh
   ```
   This will create the necessary files in the `publish` directory.

2. Set up secrets:
   ```bash
   mkdir -p secrets
   echo "your_secure_password" > secrets/db_root_password.txt
   echo "your_secure_password" > secrets/db_password.txt
   ```

3. Deploy:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

## Prerequisites

- Docker Engine 20.10+
- Docker Compose v2+
- Original The Sims Online game files
- At least 4GB RAM allocated to Docker

## Configuration

The server requires The Sims Online game files to function. Mount them using the `GAME_FILES_PATH` environment variable or by mounting to `/game` in the container.

Configuration is done via `config.json` which should be mapped to `/app/config.json` in the container.

## Ports

- 9000: API server
- 33100: City server
- 34100: Lot server
- 35100: Task server

## Volumes

- `/game`: Read-only mount for TSO game files
- `/nfs`: Persistent storage for lot/object saves

## Security

The production setup includes:
- Non-root user execution
- Secrets management
- Resource limits
- Network isolation