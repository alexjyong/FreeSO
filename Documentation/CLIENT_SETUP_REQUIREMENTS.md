# FreeSO Client Setup Requirements

This document outlines all the requirements and steps needed to set up a client that can connect to your FreeSO server.

## Overview

To connect to a FreeSO server, you need a properly configured client that has been modified from the original The Sims Online client. This document details the requirements for setting up such a client.

## System Requirements

### Client Machine Requirements
- **Operating System**: Windows XP or later (originally designed for Windows), or Linux/MacOS with Wine/Proton
- **RAM**: At least 1GB (2GB+ recommended)
- **Storage**: At least 2GB for game files
- **Graphics**: DirectX 9.0c compatible graphics card
- **Network**: Stable broadband connection
- **.NET Framework**: .NET Framework 4.8 (for original client compatibility)

### Server Connection Requirements
- **Internet Connection**: Stable connection to reach your FreeSO server
- **Firewall**: Ability to connect to server ports (9000, 33100, 34100, 35100 by default)
- **Router Configuration**: Port forwarding may be required if behind NAT

## Original Game Files Required

### Essential Game Files
You must have the original The Sims Online game files from version 1.1097.1.0:

1. **Core Executables**:
   - `TSOClient.exe` (or equivalent client executable)
   - `TSOClient.dll` (if present)
   - `TSOClient/` directory with all subdirectories

2. **Configuration Files**:
   - `tuning.dat` (critical game configuration)
   - `version.txt` (version information)
   - `TSOClient.exe.config` (client configuration)

3. **Game Assets**:
   - `TSOClient/Content/` directory with all subdirectories
   - `TSOClient/Content/Objects/objects.dat` (recommended)
   - `TSOClient/Content/Textures/` directory
   - `TSOClient/Content/UI/` directory
   - `TSOClient/Content/Sounds/` directory (if present)

4. **Database Files**:
   - `TSOClient/Content/Database/` directory
   - `TSOClient/Content/Database/tso_content.mdb` (or equivalent)

### Where to Obtain Game Files
- **Internet Archive**: https://archive.org/details/TheSimsOnline_201802
- **Original Installation**: From a legitimate copy of The Sims Online version 1.1097.1.0

## FreeSO Client Modifications

### 1. Protocol Patches
The original client needs to be patched to:
- Redirect authentication to your FreeSO server
- Update server connection endpoints
- Modify network protocol handling
- Adjust version checking mechanisms

### 2. Server Configuration
The client needs configuration files that specify:
- API server endpoint (e.g., `http://your-server:9000`)
- City server endpoint (e.g., `your-server:33100`)
- Lot server endpoint (e.g., `your-server:34100`)
- Task server endpoint (e.g., `your-server:35100`)

### 3. Launcher Requirements
- Custom launcher that connects to your server
- Account registration interface
- Server selection mechanism
- Patch management system

## Client Setup Process

### Step 1: Prepare the Environment
1. Install prerequisites:
   - .NET Framework 4.8 (if on Windows)
   - DirectX End-User Runtime (if on Windows)
   - Any other original game dependencies

2. Create a directory for the game files:
   ```bash
   mkdir ~/tso-client
   cd ~/tso-client
   ```

### Step 2: Obtain Original Game Files
1. Download The Sims Online client files from archive.org
2. Extract to your client directory
3. Verify all essential files are present

### Step 3: Apply FreeSO Patches
1. Navigate to the FreeSO client patching tools:
   ```bash
   cd TSOClient/FSO.Client.Patcher
   ```

2. Run the patching process:
   ```bash
   # This will modify the client to connect to your server
   # Specific patching commands depend on the FreeSO version
   ```

### Step 4: Configure Server Connection
1. Edit the client configuration file to point to your server:
   ```json
   {
     "apiEndpoint": "http://your-free-so-server:9000",
     "cityEndpoint": "your-free-so-server:33100",
     "lotEndpoint": "your-free-so-server:34100",
     "taskEndpoint": "your-free-so-server:35100",
     "serverName": "My FreeSO Server",
     "serverDescription": "A custom FreeSO server instance"
   }
   ```

2. Update any hardcoded server addresses in the client files

### Step 5: Set Up Authentication
1. Register an account on your FreeSO server
2. Ensure the client can authenticate with your server's API
3. Test authentication with a simple API call

## Network Configuration

### Required Ports
The client needs to connect to these ports on your FreeSO server:
- **9000**: API server (HTTP) - for authentication and user management
- **33100**: City server - for neighborhood browsing
- **34100**: Lot server - for lot/object interactions
- **35100**: Task server - for background tasks

### Firewall Settings
- Ensure outbound connections to your server's IP on the required ports
- If hosting the server, ensure inbound connections are allowed
- Consider using VPN for secure connections

## Client-Specific Configuration

### Graphics Settings
- Adjust graphics settings based on client machine capabilities
- Lower settings may improve performance over slower connections
- Consider texture streaming settings for better loading

### Audio Settings
- Configure audio settings for optimal experience
- Consider voice chat settings if implemented

### Performance Settings
- Adjust draw distance and object limits
- Configure memory usage settings
- Set appropriate frame rate limits

## Troubleshooting Client Setup

### Common Issues

#### Missing Game Files
- **Issue**: Client reports missing files or assets
- **Solution**: Verify all original game files are present and correctly named

#### Connection Failures
- **Issue**: Client cannot connect to server
- **Solution**: 
  - Verify server IP and ports in client configuration
  - Check firewall settings
  - Confirm server is running and accessible

#### Authentication Problems
- **Issue**: Cannot log in to the server
- **Solution**:
  - Verify account exists on your FreeSO server
  - Check API endpoint configuration
  - Confirm authentication service is running

#### Asset Loading Issues
- **Issue**: Game objects or textures don't load
- **Solution**:
  - Verify NFS data is properly shared between server and client
  - Check that required assets exist on the server
  - Confirm client has correct asset paths configured

### Diagnostic Tools

#### Network Diagnostics
```bash
# Test connectivity to server ports
telnet your-server-ip 9000
telnet your-server-ip 33100
telnet your-server-ip 34100
telnet your-server-ip 35100

# Alternative connectivity test
nc -zv your-server-ip 9000
```

#### Client Logs
- Check client log files for error messages
- Enable debug logging if available
- Compare with server logs for correlation

## Security Considerations

### Client Security
- Only use patched clients from trusted sources
- Verify integrity of game files
- Use secure connections where possible

### Server Security
- Implement proper authentication
- Protect against unauthorized access
- Monitor for suspicious client behavior

## Performance Optimization

### Client-Side Optimization
- Close unnecessary applications
- Ensure sufficient RAM allocation
- Use SSD storage if possible for faster asset loading

### Network Optimization
- Use wired connection when possible
- Minimize network latency
- Consider CDN for asset delivery

## Advanced Client Setup

### Multiple Client Profiles
- Set up different configurations for different servers
- Manage multiple account credentials securely
- Switch between server configurations easily

### Custom Content
- Understand how custom content is handled
- Verify compatibility with your server
- Manage content updates and patches

## Testing Client Setup

### Pre-Connection Testing
1. Verify all game files are present
2. Confirm server configuration is correct
3. Test network connectivity to server
4. Validate authentication credentials

### Connection Testing
1. Attempt initial connection to server
2. Verify all services respond correctly
3. Test basic functionality (login, character creation)
4. Validate asset loading and display

## Support Resources

### Community Support
- FreeSO Discord server
- GitHub issues for technical problems
- Forums for general support

### Documentation
- FreeSO client setup guides
- Troubleshooting documentation
- Configuration examples

## Conclusion

Setting up a client for FreeSO requires careful attention to both the original game requirements and the modifications needed to connect to a custom server. The key steps involve obtaining the original game files, applying FreeSO patches, configuring server connections, and ensuring proper network connectivity.

Following this guide should help you successfully set up a client that can connect to your FreeSO server. Remember that FreeSO is a complex system that replicates the original The Sims Online experience, so both server and client components must be properly configured for a successful connection.