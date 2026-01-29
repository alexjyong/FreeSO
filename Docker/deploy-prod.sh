#!/bin/bash
# Production deployment script for FreeSO server

echo "FreeSO Production Deployment Script"
echo "=================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "TSOClient/FSO.Server.Core/FSO.Server.Core.csproj" ]; then
    echo "Error: This script must be run from the FreeSO project root"
    exit 1
fi

echo "Step 1: Preparing build directory..."
chmod +x build-for-docker.sh
./build-for-docker.sh

echo ""
echo "IMPORTANT: Before proceeding with deployment, ensure that you have:"
echo "  1. Built the application successfully on a compatible system"
echo "  2. Copied the built binaries to the 'publish' directory"
echo "  3. Verified that FSO.Server.Core.dll exists in the publish directory"
echo ""

# Check if publish directory has the required files
if [ ! -f "publish/FSO.Server.Core.dll" ]; then
    echo "WARNING: publish/FSO.Server.Core.dll not found!"
    echo "Please build the application manually and place the binaries in the 'publish' directory."
    echo "See build-for-docker.sh for build instructions."
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting deployment."
        exit 1
    fi
fi

echo ""
echo "Step 2: Creating secrets directory..."
mkdir -p secrets

# Create sample secrets if they don't exist
if [ ! -f "secrets/db_root_password.txt" ]; then
    echo "Creating sample database root password..."
    echo "changeme_root_password" > secrets/db_root_password.txt
    echo "WARNING: Created a default password. CHANGE THIS FOR PRODUCTION!"
fi

if [ ! -f "secrets/db_password.txt" ]; then
    echo "Creating sample database password..."
    echo "changeme_db_password" > secrets/db_password.txt
    echo "WARNING: Created a default password. CHANGE THIS FOR PRODUCTION!"
fi

echo ""
echo "Step 3: Creating configuration file..."
if [ ! -f "config.json" ]; then
    cp TSOClient/FSO.Server/config.sample.json config.json
    echo "Created config.json from sample. Please review and customize for your environment."
else
    echo "Using existing config.json file."
fi

echo ""
echo "Step 4: Starting production services..."
echo "Running: docker-compose -f docker-compose.prod.yml up -d"
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "Deployment completed!"
echo ""
echo "Services:"
echo "- Database: freesodb-prod"
echo "- Server: freesoserver-prod"
echo ""
echo "Ports exposed:"
echo "- API: 9000"
echo "- City: 33100"
echo "- Lot: 34100"
echo "- Task: 35100"
echo ""
echo "Volumes:"
echo "- Game files: mounted from GAME_FILES_PATH (default: ./game)"
echo "- NFS data: persisted in nfs_data volume"
echo ""
echo "To check status: docker-compose -f docker-compose.prod.yml ps"
echo "To view logs: docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "IMPORTANT: Remember to change the default passwords in secrets/ directory!"
echo "Also ensure your config.json is properly configured for your environment."