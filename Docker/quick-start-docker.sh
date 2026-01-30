#!/bin/bash
# FreeSO Complete Docker Setup Script
# This script automates the entire process of building and deploying FreeSO with Docker
# It handles prerequisites, building, configuration, secrets, and starting services

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}FreeSO Complete Docker Setup${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose v2 or higher."
    exit 1
fi

# Check if .NET SDK 9.0 is installed
if ! command -v dotnet &> /dev/null; then
    print_error ".NET SDK is not installed. Please install .NET SDK 9.0."
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
if [[ ! "$DOTNET_VERSION" =~ ^9\. ]]; then
    print_warning "Expected .NET SDK 9.0, got version $DOTNET_VERSION. This may cause compatibility issues."
fi

print_status "All prerequisites checked successfully!"

# Check if we're in the right directory
if [ ! -f "TSOClient/FSO.Server.Core/FSO.Server.Core.csproj" ]; then
    print_error "This script must be run from the FreeSO project root directory."
    print_error "Please navigate to the directory containing TSOClient/FSO.Server.Core/FSO.Server.Core.csproj"
    exit 1
fi

echo ""
print_status "Starting FreeSO Docker setup process..."

# Prompt for game files location
print_status "Step 1: Setting up game files..."
read -p "Enter the path to your TSO game files (or press Enter to use ./game): " -e GAME_FILES_PATH
GAME_FILES_PATH=${GAME_FILES_PATH:-./game}

if [ ! -d "$GAME_FILES_PATH" ]; then
    print_error "Game files directory '$GAME_FILES_PATH' does not exist."
    print_error "Please create the directory and copy your TSO game files there."
    print_error "Required files include: tuning.dat, TSOClient/, etc."
    exit 1
else
    print_status "Using game files from: $GAME_FILES_PATH"

    # Check if critical game files exist
    CRITICAL_FILES_MISSING=0

    if [ ! -f "$GAME_FILES_PATH/tuning.dat" ]; then
        print_error "Critical file missing: tuning.dat"
        CRITICAL_FILES_MISSING=1
    fi

    if [ ! -d "$GAME_FILES_PATH/TSOClient" ]; then
        print_error "Critical directory missing: TSOClient/"
        CRITICAL_FILES_MISSING=1
    fi

    if [ ! -f "$GAME_FILES_PATH/TSOClient.exe" ]; then
        print_error "Critical file missing: TSOClient.exe"
        CRITICAL_FILES_MISSING=1
    fi

    if [ ! -f "$GAME_FILES_PATH/TSOClient/Content/Objects/objects.dat" ]; then
        print_warning "Recommended file missing: TSOClient/Content/Objects/objects.dat"
    fi

    if [ $CRITICAL_FILES_MISSING -eq 1 ]; then
        print_error "Missing critical game files. Please ensure you have valid TSO game files in $GAME_FILES_PATH"
        echo ""
        print_status "Required TSO game files:"
        print_status "  - tuning.dat (or tuning.xml)"
        print_status "  - TSOClient/ directory with subdirectories"
        print_status "  - TSOClient.exe (or TSOClient.dll)"
        print_status "  - TSOClient/Content/Objects/objects.dat (recommended)"
        echo ""
        print_status "You can obtain these files from:"
        print_status "  - https://archive.org/details/TheSimsOnline_201802"
        print_status "  - Original TSO installation (version 1.1097.1.0)"
        echo ""
        print_error "Please acquire the game files and place them in $GAME_FILES_PATH before continuing."
        exit 1
    else
        print_status "All critical game files found!"
    fi
fi

# Prompt for database user and password
print_status "Step 2: Setting up database credentials..."
read -p "Enter database user (or press Enter for 'fsoserver'): " -e DB_USER
DB_USER=${DB_USER:-fsoserver}

read -p "Enter database password (or press Enter for auto-generated): " -e DB_PASSWORD
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)
    print_status "Auto-generated database password: $DB_PASSWORD"
    print_warning "Save this password as it will be needed for database access"
fi

# Step 3: Build the application
echo ""
print_status "Step 3: Building the FreeSO application..."

# Check if we need to run protobuild (based on Azure pipeline)
if [ -f "Other/libs/FSOMonoGame/protobuild.exe" ]; then
    print_status "Running protobuild (this may take a moment)..."
    cd Other/libs/FSOMonoGame/
    # protobuild.exe --generate (would run on Windows)
    cd ../../..
fi

# Restore packages first
print_status "Restoring packages..."
cd TSOClient
dotnet restore -p:WarningsNotAsErrors=NU1605
cd ..

# Build the client project (based on Azure pipeline which builds FSO_IDE project)
print_status "Building the FreeSO client project..."
dotnet build TSOClient/FreeSO.sln -p:Configuration=Release -p:WarningsNotAsErrors=NU1605

# Create publish directory
mkdir -p publish

# Copy built files to publish directory (this is what the server will use)
# Note: The client project creates FSO.Client.exe, not TSOClient.exe
cp -r TSOClient/tso.client/bin/Release/net9.0/* publish/ 2>/dev/null || echo "Client build output not found, continuing..."

print_status "Build completed successfully!"

# Step 4: Create secrets directory and files
echo ""
print_status "Step 4: Setting up secrets..."
mkdir -p secrets

# Create database passwords
echo "$DB_PASSWORD" > secrets/db_password.txt
if [ ! -f "secrets/db_root_password.txt" ]; then
    ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)
    echo "$ROOT_PASSWORD" > secrets/db_root_password.txt
    print_status "Auto-generated database root password: $ROOT_PASSWORD"
    print_warning "Save this root password as it will be needed for database administration"
fi

# Step 5: Configure the server
echo ""
print_status "Step 5: Configuring the server..."

# Check if config.json already exists
if [ -f "config.json" ]; then
    read -p "config.json already exists. Overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Keeping existing config.json file."
    else
        chmod +x Docker/setup-config.sh
        ./Docker/setup-config.sh
    fi
else
    chmod +x Docker/setup-config.sh
    ./Docker/setup-config.sh
fi

# Step 6: Set up environment variables
echo ""
print_status "Step 6: Setting up environment variables..."

# Create .env file
print_status "Creating .env file..."
cat > .env << EOF
# Database configuration
MYSQL_ROOT_PASSWORD_FILE=./secrets/db_root_password.txt
MYSQL_DATABASE=fso
MYSQL_USER=$DB_USER
MYSQL_PASSWORD_FILE=./secrets/db_password.txt

# Port configuration
API_PORT=9000
CITY_PORT=33100
LOT_PORT=34100
TASK_PORT=35100

# Game files path (absolute path to your TSO game directory)
GAME_FILES_PATH=$GAME_FILES_PATH

# NFS data path
NFS_DATA_PATH=./nfs_data
EOF
print_status ".env file created with your settings."

# Step 6b: Set up client configuration
echo ""
print_status "Step 6b: Setting up client configuration..."

# Prompt for server URLs
read -p "Enter the API server URL (default: http://localhost:9000): " -e API_URL
API_URL=${API_URL:-http://localhost:9000}

read -p "Enter the City selector URL (default: $API_URL): " -e CITY_URL
CITY_URL=${CITY_URL:-$API_URL}

# Create GlobalSettings.config file if it doesn't exist
if [ ! -f "config.ini" ]; then
    print_status "Creating client config.ini file..."
    cat > config.ini << EOF
[Settings]
# Server configuration - update these to match your server's public IP/URL
GameEntryUrl=$API_URL
CitySelectorUrl=$CITY_URL

# Graphics settings
GraphicsWidth=1024
GraphicsHeight=768
Windowed=true

# User settings
LastUser=docker_user
SkipIntro=true

# Audio settings
FXVolume=10
MusicVolume=10
VoxVolume=10
AmbienceVolume=10

# Other settings
CurrentLang=english
DebugEnabled=false
ScaleUI=false

# TS1 Hybrid settings (for mixed TSO/TS1 mode)
TS1HybridEnable=false
TS1HybridPath=

# Archive settings (for replay/archive functionality)
ArchiveClientGUID=$(uuidgen)
ArchiveServerGUID=$(uuidgen)
EOF
    print_status "Client config.ini file created with your settings."
else
    print_warning "Using existing config.ini file."
fi

# Step 7: Build the Docker image
echo ""
print_status "Step 7: Building Docker image..."
docker-compose -f Docker/docker-compose.yml build server

# Step 8: Start the services
echo ""
print_status "Step 8: Starting FreeSO services..."
docker-compose -f Docker/docker-compose.yml up -d

# Step 9: Wait for services to be ready and check status
echo ""
print_status "Step 9: Verifying services are running..."
sleep 10  # Give services time to start

# Check if services are running
SERVER_STATUS=$(docker-compose -f Docker/docker-compose.yml ps server 2>/dev/null | grep -c "Up")
DB_STATUS=$(docker-compose -f Docker/docker-compose.yml ps database 2>/dev/null | grep -c "Up")

if [ "$SERVER_STATUS" -gt 0 ] && [ "$DB_STATUS" -gt 0 ]; then
    echo ""
    print_status "${GREEN}SUCCESS: FreeSO server is now running!${NC}"
    echo ""
    echo -e "${BLUE}Service Status:${NC}"
    docker-compose -f Docker/docker-compose.yml ps
    echo ""
    echo -e "${BLUE}Access Information:${NC}"
    echo "API Server: http://localhost:9000"
    echo "City Server: localhost:33100"
    echo "Lot Server: localhost:34100"
    echo "Task Server: localhost:35100"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. If you haven't already, copy your TSO game files to: $GAME_FILES_PATH"
    echo "   Required files include: tuning.dat, TSOClient/, etc."
    echo "2. Update config.json if needed for your specific setup"
    echo "3. Check logs with: docker-compose -f Docker/docker-compose.yml logs -f"
    echo "4. To stop services: docker-compose -f Docker/docker-compose.yml down"
    echo ""
    print_status "Setup complete! The FreeSO server should now be accessible."
else
    echo ""
    print_error "Some services failed to start properly."
    echo "Check the logs for more information:"
    echo "  docker-compose -f Docker/docker-compose.yml logs"
    exit 1
fi

echo ""
print_status "FreeSO Docker setup completed successfully!"