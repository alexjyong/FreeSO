# FreeSO Server Docker Setup Guide

This guide explains how to deploy the FreeSO server using Docker containers.

## Prerequisites

Before setting up the FreeSO server with Docker, you need:

1. **Docker Engine** (version 20.10 or higher)
2. **Docker Compose** (version 2.0 or higher)
3. **Original The Sims Online game files** (version 1.1097.1.0)
   - Available from: https://archive.org/details/TheSimsOnline_2002
4. **At least 4GB of RAM** allocated to Docker (more recommended)
5. **Sufficient disk space** for the database and NFS data
6. **.NET SDK 9.0** (for building the server)

## Quick Start

### 1. Clone the FreeSO Repository

```bash
git clone https://github.com/riperiperi/FreeSO.git
cd FreeSO
```

### 2. Prepare Game Files

1. Download The Sims Online game files from archive.org
2. Extract them to a local directory (e.g., `./game`)
3. Ensure the directory contains files like `tuning.dat`, `TSOClient`, etc.

### 3. Configure the Server

You have two options for configuring the server:

**Option 1: Use the automated setup script (Recommended)**
   ```bash
   chmod +x Docker/setup-config.sh
   ./Docker/setup-config.sh
   ```
   This script will automatically create and configure the config.json file for you.

**Option 2: Manual configuration**
   1. Copy the sample configuration:
      ```bash
      cp TSOClient/FSO.Server/config.sample.json config.json
      ```

   2. Edit `config.json` to match your setup:
      - Set `"gameLocation"` to `"./game/"` (this will map to the container's `/game`)
      - Set `"simNFS"` to `"./nfs"` (this will map to the container's `/nfs`)
      - Update database connection string to use `"database=fso;server=database;uid=fsoserver;pwd=password;"`

### 4. Set Up Environment Variables

Create a `.env` file in the project root:

```bash
# Database configuration
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=fso
MYSQL_USER=fsoserver
MYSQL_PASSWORD=password

# Port configuration
API_PORT=9000
CITY_PORT=33100
LOT_PORT=34100
TASK_PORT=35100

# Game files path (absolute path to your TSO game directory)
GAME_FILES_PATH=/path/to/your/tso/game/files
```

### 5. Build and Start the Services

```bash
# Build the server image (this will take some time on first build)
docker compose build server

# Start the services
docker compose up -d
```

The server will start and automatically initialize the database.

## Configuration Details

### Main Configuration File

The FreeSO server expects the `config.json` file to be in the same directory as the server binaries. In the Docker container, this is `/app/` directory.

The docker-compose file correctly mounts the main configuration file to this location:

```yaml
volumes:
  # Mount main configuration file to the correct location
  - ./config.json:/app/config.json:ro
```

### Additional Configuration Files

The Docker image also includes other necessary configuration files:
- `NLog.config` - Logging configuration
- `appsettings.json` and `appsettings.Development.json` - API server settings

These are copied during the Docker build process to ensure the server has all required configuration files.

### Database Configuration

The default configuration uses MariaDB 10.5, which is recommended for FreeSO. The database will persist in a named volume (`db_data`).

### Network Ports

The following ports are exposed by default:
- `9000`: User API (HTTP)
- `33100`: City server
- `34100`: Lot server
- `35100`: Task server

Adjust these in your `.env` file if you need different ports.

### Volumes

The setup uses Docker volumes for persistent data:
- `db_data`: Database files
- `nfs_data`: NFS lot/object saves

Game files are mounted as a read-only volume from your local system.

## Advanced Configuration

### Custom Server Configuration

To customize the server configuration:

1. Modify the `config.json` file before starting the containers
2. Pay special attention to:
   - `secret`: Change this to a unique 64-character hex string
   - `services.userApi.bindings`: Update to match your server's public IP
   - `services.cities[*].public_host` and `services.lots[*].public_host`: Update to match your server's public IP

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_ROOT_PASSWORD` | rootpassword | Root password for MariaDB |
| `MYSQL_DATABASE` | fso | Database name |
| `MYSQL_USER` | fsoserver | Database user |
| `MYSQL_PASSWORD` | password | Database password |
| `API_PORT` | 9000 | API server port |
| `GAME_FILES_PATH` | ./game | Path to TSO game files |

### Production Considerations

For production deployments:

1. Use strong passwords for database credentials
2. Configure SSL/TLS for the API server
3. Set up proper firewall rules
4. Regular backups of the database and NFS volumes
5. Monitor resource usage and scale as needed

### Production Build Process

For production deployments, use the following build process:

1. Build the application on your host system:
   ```bash
   chmod +x Docker/build-for-docker.sh
   ./Docker/build-for-docker.sh
   ```

2. Create secrets directory and files:
   ```bash
   mkdir -p secrets
   echo "your_secure_db_root_password" > secrets/db_root_password.txt
   echo "your_secure_db_password" > secrets/db_password.txt
   ```

3. Copy and customize the configuration:
   ```bash
   cp TSOClient/FSO.Server/config.sample.json config.json
   # Edit config.json to match your production settings
   ```

4. Deploy with production compose file (located in Docker/ directory):
   ```bash
   docker-compose -f Docker/docker-compose.prod.yml up -d
   ```

### Production Security

The production setup includes:

- Non-root user execution for the server container
- Secrets management for database credentials
- Resource limits to prevent resource exhaustion
- Health checks for both services
- Network isolation between services

### Production Monitoring

For production monitoring, consider:

1. Log aggregation with tools like ELK stack or Fluentd
2. Metrics collection with Prometheus and Grafana
3. Health monitoring with alerts
4. Performance monitoring of the .NET application

### Backup Strategy

Set up automated backups for:

1. Database: Regular MariaDB dumps
2. NFS data: Periodic snapshots of the NFS volume
3. Configuration: Version control for config files

Example backup script:
```bash
#!/bin/bash
# Database backup
docker exec freesodb-prod mysqldump -u fsoserver -p$(cat secrets/db_password.txt) fso > backup_$(date +%Y%m%d_%H%M%S).sql

# NFS data backup (stop the server first)
docker-compose -f Docker/docker-compose.prod.yml stop server
tar -czf nfs_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /path/to/nfs/data .
docker-compose -f Docker/docker-compose.prod.yml start server
```

### Scaling Considerations

The FreeSO server architecture supports horizontal scaling:

1. Multiple server instances behind a load balancer
2. Shared NFS storage for consistent lot/object data
3. Centralized database for user and game state
4. Proper session management for client connections

## Managing the Server

### Starting the Server

```bash
docker compose up -d
```

### Stopping the Server

```bash
docker compose down
```

### Viewing Logs

```bash
# View all logs
docker compose logs

# View specific service logs
docker compose logs server
docker compose logs database
```

### Accessing the Database

```bash
docker compose exec database mysql -u fsoserver -p fso
```

### Updating the Server

1. Pull the latest FreeSO code
2. Rebuild the server image: `docker compose build server`
3. Restart the services: `docker compose up -d`

## Troubleshooting

### Common Issues

#### Database Connection Errors
- Ensure the database service is running: `docker compose ps`
- Check that the database connection string in config.json is correct
- Verify database credentials in the `.env` file

#### Game Files Not Found
- Verify that the `GAME_FILES_PATH` in `.env` points to the correct directory
- Ensure the game directory contains the required TSO files
- Check that the directory has proper read permissions

#### Port Conflicts
- Adjust port numbers in the `.env` file if they conflict with other services
- Check for firewalls blocking the required ports

#### NFS Data Not Persisting
- Verify that the `nfs_data` volume is properly created
- Check that the NFS directory has proper write permissions

#### Build Issues
- The build process may fail due to .NET package compatibility issues
- The Dockerfile is configured to treat downgrade warnings as non-errors
- If build fails, check the Dockerfile in `TSOClient/FSO.Server.Core/Dockerfile`

### Useful Commands

```bash
# Check service status
docker compose ps

# Restart a specific service
docker compose restart server

# Scale services (if needed)
docker compose up -d --scale server=2

# Clean up unused volumes (careful!)
docker volume prune

# Build without cache (if needed)
docker compose build --no-cache server
```

## Backup and Recovery

### Backing Up Data

```bash
# Backup database
docker compose exec database mysqldump -u fsoserver -p fso > backup.sql

# Backup NFS data (stop the server first)
docker compose stop server
docker run --rm -v freesodb_nfs_data:/volume -v $(pwd):/backup alpine tar czf /backup/nfs_backup.tar.gz -C /volume .
docker compose start server
```

### Restoring Data

```bash
# Restore database
docker compose exec -T database mysql -u fsoserver -p fso < backup.sql
```

## Scaling Considerations

The FreeSO server can be scaled horizontally by running multiple instances, but you should ensure:
- Shared NFS storage for consistent lot/object data
- Proper load balancing for API requests
- Coordinated database access
- Consistent configuration across instances

## Security Best Practices

1. Use strong, unique passwords
2. Regularly update Docker images
3. Limit network exposure to necessary ports only
4. Regular backups of critical data
5. Monitor logs for suspicious activity
6. Keep the FreeSO codebase updated

## Development Notes

### Building the Server Manually

If you need to build the server manually before Dockerizing:

```bash
cd TSOClient/FSO.Server.Core
dotnet publish -c Release -r linux-x64 --self-contained false -p:WarningsNotAsErrors=NU1605
```

### Docker Build Considerations

Due to the complex nature of the FreeSO codebase, which includes mixed .NET Framework and .NET Core components, building directly in Docker may present challenges:

- The FreeSO project uses legacy .NET Framework libraries that may not be fully compatible with newer .NET versions
- Multiple projects with different target frameworks may cause build conflicts
- Some dependencies may require specific .NET Framework versions

If the Docker build fails, consider these alternatives:
1. Build the application on your host system first, then copy the binaries to the container
2. Use a Windows-based build environment for initial compilation
3. Modify individual project files to resolve compatibility issues

### Alternative Docker Strategy

For production deployments, consider a two-stage approach:
1. Build the application on a compatible host environment
2. Copy the compiled binaries to a minimal runtime container

Example of a runtime-only Dockerfile:
```dockerfile
FROM mcr.microsoft.com/dotnet/runtime:9.0
WORKDIR /app

# Copy pre-built application binaries
COPY ./publish/ .

# Install runtime dependencies
RUN apt-get update && apt-get install -y libc6-dev && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /game /nfs

# Set up volumes for game files and NFS data
VOLUME ["/game", "/nfs"]

# Expose ports used by FreeSO server
EXPOSE 9000 33100 34100 35100

# Copy configuration
COPY config.json .

# Entry point
ENTRYPOINT ["dotnet", "FSO.Server.Core.dll"]
```

### Docker Build Context

The Dockerfile is designed to:
- Build the FreeSO server from source inside the container
- Handle .NET package compatibility issues by treating downgrade warnings as non-errors
- Copy the necessary project files first for optimal layer caching
- Create a final lightweight runtime image

Note that due to the mixed .NET Framework/.NET Core nature of the project, you may need to adjust the build process based on your specific environment and requirements.