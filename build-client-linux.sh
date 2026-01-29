#!/bin/bash
# FreeSO Client Build Script for Linux
# This script automates the build process for the FreeSO client on Linux

set -e  # Exit on any error

# Default configuration
CONFIGURATION="Release"
CLEAN=false
SKIP_RESTORE=false
BUILD_ONLY=false
RUN=false
PUBLISH=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --skip-restore)
            SKIP_RESTORE=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --run)
            RUN=true
            shift
            ;;
        --publish)
            PUBLISH=true
            shift
            ;;
        -h|--help)
            echo "FreeSO Client Build Script for Linux"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -c, --configuration [Debug|Release]  Build configuration (default: Release)"
            echo "  --clean                              Clean build artifacts before building"
            echo "  --skip-restore                       Skip restoring dependencies"
            echo "  --build-only                         Build only, don't run or publish"
            echo "  --run                                Run the client after building"
            echo "  --publish                            Publish the client to a distributable format"
            echo "  -h, --help                           Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "=== FreeSO Client Build Script for Linux ==="
echo "Configuration: $CONFIGURATION"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_header "Checking prerequisites..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed or not in PATH"
    exit 1
fi

# Check if dotnet is installed
if ! command -v dotnet &> /dev/null; then
    print_error ".NET SDK is not installed or not in PATH"
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
print_status "Found .NET SDK version: $DOTNET_VERSION"

# Check if we're in the right directory
if [ ! -f "TSOClient/FSO.Server.Core/FSO.Server.Core.csproj" ]; then
    print_error "This script must be run from the FreeSO project root directory."
    print_error "Please navigate to the directory containing TSOClient/FSO.Server.Core/FSO.Server.Core.csproj"
    exit 1
fi

if [ "$CLEAN" = true ]; then
    print_header "Cleaning build artifacts..."
    
    find . -name bin -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name obj -type d -exec rm -rf {} + 2>/dev/null || true
    
    print_status "Clean complete!"
fi

if [ "$SKIP_RESTORE" = false ]; then
    print_header "Restoring dependencies..."
    # Restore dependencies for the client project specifically
    dotnet restore TSOClient/tso.client/FSO.Client.csproj -p:WarningsNotAsErrors=NU1605
    if [ $? -ne 0 ]; then
        print_error "Failed to restore dependencies for client"
        exit 1
    fi
    print_status "Dependencies restored!"
fi

print_header "Building FreeSO Client ($CONFIGURATION)..."
# Build the client project specifically, not the server
dotnet build TSOClient/tso.client/FSO.Client.csproj -c $CONFIGURATION --no-restore -p:WarningsNotAsErrors=NU1605
if [ $? -ne 0 ]; then
    print_error "Client build failed"
    exit 1
fi

if [ "$PUBLISH" = true ]; then
    print_header "Publishing FreeSO Client..."
    # Publish the client project specifically
    dotnet publish TSOClient/tso.client/FSO.Client.csproj -c $CONFIGURATION -r linux-x64 --self-contained false --no-build -p:WarningsNotAsErrors=NU1605 -o publish
    if [ $? -ne 0 ]; then
        print_error "Publish failed"
        exit 1
    fi
    print_status "Publish complete! Files are in publish directory."
fi

print_header "Build Complete!"
EXECUTABLE_PATH="TSOClient/tso.client/bin/$CONFIGURATION/net9.0/TSOClient"
print_status "Client executable: $EXECUTABLE_PATH"
echo ""
print_status "TIP: Use --publish to create a distributable package."
print_status "TIP: You'll need original TSO game files in a 'game' directory to run the client."

if [ "$RUN" = true ]; then
    print_header "Launching FreeSO Client..."
    if [ -f "$EXECUTABLE_PATH" ]; then
        # For Linux, we need to run with dotnet
        dotnet "$EXECUTABLE_PATH"
    else
        print_error "Client executable not found at expected location."
        print_warning "You may need to run: dotnet run --project TSOClient/tso.client/TSOClient.csproj"
    fi
fi