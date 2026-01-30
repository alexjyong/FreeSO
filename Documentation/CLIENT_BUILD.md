# FreeSO Client Build Guide

## Overview

This guide explains how to build the FreeSO client from source code and connect it to either a local sandbox environment or a FreeSO server.

## Prerequisites

Before building the FreeSO client, you need:

1. **.NET SDK 9.0** - For building the application
2. **MonoGame 3.8** - Graphics framework dependency
3. **Git** - For cloning the repository
4. **Original The Sims Online game files** (version 1.1097.1.0)
   - Available from: https://archive.org/details/TheSimsOnline_201802
5. **At least 4GB of RAM** for building
6. **Approximately 2GB of disk space** for the build process

### For Linux Users
Additional prerequisites:
- **SDL2 development libraries**: `sudo apt-get install libsdl2-dev` (Ubuntu/Debian)
- **OpenGL development libraries**: `sudo apt-get install libgl1-mesa-dev` (Ubuntu/Debian)
- **X11 development libraries**: `sudo apt-get install libx11-dev libxcursor-dev libxi-dev libxinerama-dev libxrandr-dev` (Ubuntu/Debian)

## Cloning the Repository

```bash
git clone https://github.com/riperiperi/FreeSO.git
cd FreeSO
```

## Building the Client

### 1. Navigate to the Client Directory

```bash
cd TSOClient
```

### 2. Restore NuGet Packages

```bash
dotnet restore -p:WarningsNotAsErrors=NU1605
```

This command restores all necessary NuGet packages and treats downgrade warnings as non-errors, which is important for the mixed .NET Framework/.NET Core dependencies in FreeSO.

### 3. Build the Client

```bash
dotnet build TSOClient.sln -c Release -p:WarningsNotAsErrors=NU1605
```

This builds the entire client solution in Release mode, with warnings about package downgrades treated as non-errors.

### 4. Alternative: Build Specific Projects

If you want to build just the main client:

```bash
cd tso.client
dotnet build -c Release -p:WarningsNotAsErrors=NU1605
```

## Client Configuration

### 1. Prepare Game Files

The FreeSO client requires original The Sims Online game files.
1. Download The Sims Online game files from archive.org
2. Extract them to one of the default locations, OR
3. Set the `StartupPath` in `config.ini` to point to your game directory

The client searches for these files in specific locations:

##### Default Search Locations
The client searches for game files in this order:
1. `../The Sims Online/TSOClient/` (relative to the client executable)
2. `game/TSOClient/` (for Linux systems)
3. Windows registry location: `C:\Program Files\Maxis\The Sims Online\TSOClient\`

##### Required Game Files
The client verifies the game installation by looking for `tuning.dat` in the game directory.

For manual setup, ensure your game directory contains:
- `tuning.dat` (or `tuning.xml`)
- `TSOClient/` directory with subdirectories
- `TSOClient.exe` (or equivalent client executable)
- `UserData/` directory (if available)


For Docker deployments, the game files should be mounted to `/game` in the container, and the `gameLocation` in the server's `config.json` should be set to `"./game/"`.

For local client development, place your game files in a `game/` directory relative to the client executable, ensuring:
- `game/tuning.dat` exists
- `game/TSOClient/` directory with subdirectories exists
- `game/TSOClient.exe` (or equivalent) exists
- Other required TSO files exist in the game directory

### 2. Client Configuration vs. Server Configuration

It's important to understand that the FreeSO client and server have separate configuration systems:

#### Server Configuration (`config.json`)
- Used by the **server** application
- Contains database settings, service endpoints, and server-specific parameters
- Located on the server system
- Not used by the client directly

#### Client Configuration
- The **client** has its own configuration system
- Typically connects to servers through the launcher interface
- Uses server endpoints specified at runtime or through client-side configuration
- Stores user preferences, graphics settings, and local paths to game files
- Does not use the server's `config.json` file

### 3. Sandbox Mode vs. Server Mode

The FreeSO client can operate in two modes:

#### Sandbox Mode
- Local-only operation without server dependencies
- No database or networking required
- Ideal for development and testing
- Still requires original TSO game files for core functionality
- Access through the client's "Sandbox Mode" option
- Uses local simulation instead of connecting to external servers

#### Server Mode
- Connects to a FreeSO server instance
- Requires network connectivity to the server
- Full multiplayer functionality
- Requires original TSO game files
- Access through the normal login interface
- The client dynamically connects to the server's API, city, lot, and task endpoints

## Running the Client

### 1. From the Command Line

The main FreeSO client executable is located in the FSO.Windows project. On Windows, you can run the .exe directly:

```bash
cd TSOClient/FSO.Windows/bin/Release/net9.0-windows/
./FSO.Windows.exe
```

On Linux, you need to run the client library with the dotnet command:

```bash
cd TSOClient/tso.client/bin/Release/net9.0/
dotnet FSO.Client.dll
```

On Windows PowerShell, you can also use:
```powershell
cd TSOClient\tso.client\bin\Release\net9.0\
dotnet.exe FSO.Client.dll
```

### 2. With Custom Game Directory

```bash
# On Windows
./FSO.Windows.exe --game-path ../game

# On Linux
dotnet FSO.Client.dll --game-path ../game
```

### 3. For Development

For development purposes, you can run with additional debugging options:

```bash
# On Windows
./FSO.Windows.exe --debug-mode --skip-intro

# On Linux
dotnet FSO.Client.dll --debug-mode --skip-intro
```

### 4. Common Windows PowerShell Issues

If you encounter the error:
```
'TSOClient' could not be loaded. For more information, run 'Import-Module TSOClient'.
```

This happens when PowerShell interprets the path as a module. To fix this:

1. Use the full path with the `dotnet` command:
   ```powershell
   dotnet.exe "$pwd\TSOClient\tso.client\bin\Release\net9.0\FSO.Client.dll"
   ```

2. Or run the Windows executable directly:
   ```powershell
   cd TSOClient\FSO.Windows\bin\Release\net9.0-windows\
   .\FSO.Windows.exe
   ```

3. Make sure you have the original TSO game files in the expected location before running the client

## Automated Client Build Scripts

To simplify the build process, we provide automated build scripts for both Windows and Linux:

### Windows Build Script

Use the PowerShell script to automate the entire build process:

```powershell
# Run the build script
./Docker/build-client-windows.ps1

# With specific configuration
./Docker/build-client-windows.ps1 -Configuration Debug

# Clean build
./Docker/build-client-windows.ps1 -Clean

# Build and publish
./Docker/build-client-windows.ps1 -Publish

# Build and run
./Docker/build-client-windows.ps1 -Run
```

### Linux Build Script

Use the shell script to automate the entire build process on Linux:

```bash
# Make the script executable
chmod +x Docker/build-client-linux.sh

# Run the build script
./Docker/build-client-linux.sh

# With specific configuration
./Docker/build-client-linux.sh --configuration Debug

# Clean build
./Docker/build-client-linux.sh --clean

# Build and publish
./Docker/build-client-linux.sh --publish

# Build and run
./Docker/build-client-linux.sh --run
```

### Script Features

Both scripts provide:
- Prerequisite checking (Git, .NET SDK, etc.)
- Automatic dependency restoration
- Clean build options
- Build configuration selection (Debug/Release)
- Publishing capabilities
- Post-build execution options
- Error handling and status reporting

## Connecting to a FreeSO Server

### 1. Server Connection Configuration

The FreeSO client connects to servers dynamically and is **not hardcoded** to any specific server. Connection is typically configured through:

1. **Launcher Interface**: The FreeSO launcher provides a user interface to select and connect to different servers
2. **Command-Line Parameters**: Server endpoints can be specified when launching the client
3. **Client Configuration Files**: Some client implementations allow server endpoints to be specified in client-side configuration files

### 2. Required Server Information

To connect to a FreeSO server, you'll need to provide the client with:

- **API Endpoint**: HTTP endpoint for authentication and user services (e.g., `http://your-server:9000`)
- **City Server Endpoint**: For neighborhood browsing (e.g., `your-server:33100`)
- **Lot Server Endpoint**: For lot/object interactions (e.g., `your-server:34100`)
- **Task Server Endpoint**: For background tasks (e.g., `your-server:35100`)

### 3. Connection Process

1. Launch the FreeSO client
2. Select your server from the launcher interface or specify endpoints via command-line
3. Enter your credentials (register if needed)
4. The client will connect to the API server first for authentication
5. After authentication, it will connect to the appropriate game servers
6. The client can connect to different FreeSO servers by changing the configuration

### 4. Dynamic Server Selection

The FreeSO client architecture supports connecting to different servers:
- Clients are not compiled with hardcoded server addresses
- Server connection information is provided at runtime
- Multiple server configurations can be stored in the client launcher
- Users can switch between different FreeSO server instances

## Linux Compatibility

### Current State

FreeSO can run on Linux, but with some important considerations:

1. **MonoGame Compatibility**: FreeSO uses MonoGame which has Linux support, but some features may behave differently
2. **Dependencies**: Linux requires additional native libraries for graphics and input
3. **Game Files**: The original TSO game files work the same on Linux as on Windows
4. **Networking**: Network protocols are platform-independent

### Building for Linux

To build specifically for Linux:

```bash
dotnet publish tso.client/TSOClient.csproj -c Release -r linux-x64 --self-contained false -p:WarningsNotAsErrors=NU1605
```

### Running on Linux

The client can be run on Linux with:

```bash
cd tso.client/bin/Release/net9.0/linux-x64/
./TSOClient
```

### Known Issues on Linux

- Some audio features may not work identically to Windows
- Graphics rendering may differ slightly due to OpenGL vs DirectX differences
- Input handling may vary depending on the desktop environment
- Font rendering may appear different

### Relationship to Simitone

Simitone (The Sims 1 reimplementation) has better Linux compatibility, but FreeSO (The Sims Online) can also run on Linux. The underlying MonoGame framework supports Linux, but FreeSO has additional dependencies and compatibility requirements that may require more configuration on Linux systems.

## Troubleshooting Common Issues

### 1. Build Issues

#### Package Downgrade Warnings
If you encounter package downgrade warnings treated as errors:
```bash
dotnet build -p:WarningsNotAsErrors=NU1605
```

#### Missing Dependencies
If MonoGame or other dependencies fail to restore:
```bash
dotnet clean
dotnet restore -p:WarningsNotAsErrors=NU1605
dotnet build -p:WarningsNotAsErrors=NU1605
```

### 2. Runtime Issues

#### Missing Game Files
- Verify that the game files directory contains the required files
- Check that the path is correctly specified in the client configuration
- Ensure the client has read permissions to the game files

#### Connection Issues
- Verify that the server endpoints are accessible
- Check firewall settings on both client and server
- Confirm that the server is running and accepting connections

#### Graphics Issues
- Ensure your system has proper graphics drivers installed
- On Linux, verify that OpenGL libraries are available
- Try running in windowed mode if fullscreen causes issues

### 3. Platform-Specific Issues

#### Linux Audio Issues
```bash
# Install ALSA development libraries
sudo apt-get install libasound2-dev
```

#### Linux Graphics Issues
```bash
# Install Mesa OpenGL libraries
sudo apt-get install mesa-common-dev
```

## Development Notes

### Project Structure

The FreeSO client consists of several key components:
- `tso.client/` - Main client application
- `tso.common/` - Common utilities and base classes
- `tso.content/` - Content management system
- `tso.files/` - File format handlers
- `tso.simantics/` - Virtual machine for game logic
- `tso.sound/` - Audio system
- `tso.vitaboy/` - 3D character rendering
- `tso.world/` - 3D world rendering

### Debugging

For debugging purposes, you can:
- Use the sandbox mode for local testing without server dependencies
- Enable debug mode with `--debug-mode` flag
- Check the client logs in the `logs/` directory
- Use the built-in debug tools accessible via F1-F12 keys

## Security Considerations

1. **Game Files**: Keep original TSO game files secure and do not redistribute them
2. **Client Configuration**: Store server credentials securely
3. **Network Traffic**: Be aware that client-server communication may not be encrypted by default
4. **Personal Information**: Do not store personal information in client configurations

## Performance Optimization

### For Better Performance
- Close other applications to free up resources
- Ensure sufficient RAM is allocated to the client
- Use SSD storage for faster asset loading
- Adjust graphics settings based on your hardware

### For Development
- Use sandbox mode for faster iteration
- Disable unnecessary features during development
- Monitor memory usage during extended sessions

## Conclusion

Building the FreeSO client requires attention to the .NET compatibility issues inherent in the mixed .NET Framework/.NET Core codebase. The build process is straightforward once the prerequisites are met, and the client can operate in either sandbox mode for local development or connect to a FreeSO server for multiplayer functionality.

Linux compatibility is possible but may require additional configuration compared to Windows. The underlying MonoGame framework supports Linux, but users may encounter platform-specific issues that need resolution.

Remember to always respect the intellectual property rights of the original game files and only use them in accordance with EA's terms of service.