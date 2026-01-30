# Connecting Clients to Your FreeSO Server

This document explains how to set up and configure clients to connect to your FreeSO server.

## Overview

FreeSO recreates the original The Sims Online server experience, allowing players to connect with a modified version of the original game client. This document covers the process of preparing, configuring, and connecting clients to your server.

## Client Requirements

### 1. Original The Sims Online Client
- You need the original The Sims Online client (version 1.1097.1.0)
- Available from: https://archive.org/details/TheSimsOnline_201802
- The client must be the original version to work with FreeSO's protocol implementation

### 2. FreeSO Client Patches
- The FreeSO project includes patches to redirect the client to your custom server
- These patches modify the client's connection endpoints
- Applied to the original game client to enable custom server connectivity

## Client Setup Process

### 1. Obtain Original Game Files
1. Download The Sims Online client from archive.org
2. Extract the files to a directory (e.g., `~/tso-client`)
3. Verify you have the required files:
   - `TSOClient.exe` (or equivalent)
   - `tuning.dat`
   - `TSOClient/` directory with game assets
   - All original game textures, objects, and UI elements

### 2. Apply FreeSO Patches
1. Navigate to the FreeSO client directory:
   ```bash
   cd TSOClient
   ```

2. Run the patching process (this redirects the client to your server):
   ```bash
   # The patching process modifies the client's connection endpoints
   # This is typically done through the FreeSO launcher or patcher
   ```

### 3. Configure Client Settings
1. Locate the client configuration file (typically `config.json` or similar)
2. Update the server connection settings:
   ```json
   {
     "apiEndpoint": "http://your-server-ip:9000",
     "cityEndpoint": "your-server-ip:33100",
     "lotEndpoint": "your-server-ip:34100",
     "taskEndpoint": "your-server-ip:35100"
   }
   ```

### 4. Set Up the Launcher
1. The FreeSO project includes a custom launcher that handles:
   - Authentication with your server
   - Server selection interface
   - Patch management
2. Configure the launcher to point to your server's API endpoint

## Connection Process

### 1. Authentication
- Clients authenticate through the User API at port 9000
- The server maintains its own user database
- Registration is handled through the web API

### 2. City Connection
- After authentication, clients connect to city servers (port 33100)
- This enables neighborhood browsing and city navigation

### 3. Lot Connection
- When entering lots, clients connect to lot servers (port 34100)
- This handles lot simulation and object interactions

### 4. Task Connection
- Background tasks and communications use the task server (port 35100)

## Testing Client Connections

### 1. Verify Server Status
Before attempting client connections, ensure your server is running:
```bash
docker-compose -f Docker/docker-compose.yml ps
```

### 2. Test API Endpoint
Verify the API server is accessible:
```bash
curl http://your-server-ip:9000/api/status
```

### 3. Check Port Accessibility
Ensure the required ports are accessible from client machines:
- Port 9000 (API)
- Port 33100 (Cities)
- Port 34100 (Lots)
- Port 35100 (Tasks)

### 4. Client Connection Test
1. Launch the patched TSO client
2. Attempt to log in using credentials registered on your server
3. Monitor server logs for connection attempts:
   ```bash
   docker-compose -f Docker/docker-compose.yml logs -f server
   ```

## Troubleshooting Common Issues

### 1. Connection Refused
- Verify the server is running: `docker-compose ps`
- Check firewall settings allow access to required ports
- Ensure the client configuration points to the correct IP/port

### 2. Authentication Failures
- Verify the API endpoint in client config matches your server
- Check that the database is accessible and populated with users
- Ensure the authentication service is running

### 3. Missing Game Assets
- Confirm all original game files are present in the client directory
- Verify the server has access to the same game files
- Check that file paths in configuration are correct

### 4. Protocol Mismatch
- Ensure the client and server versions are compatible
- Verify that patches are correctly applied to the client
- Check that the server is using the same protocol version as the client

## Security Considerations

### 1. Network Security
- Use VPN or secure connections for remote access
- Implement proper firewall rules
- Consider SSL/TLS for API communications

### 2. Client Verification
- Only allow connections from properly patched clients
- Implement connection rate limiting
- Monitor for unauthorized client modifications

## Performance Optimization

### 1. Client-Side
- Ensure clients have sufficient hardware resources
- Optimize graphics settings for network conditions
- Use stable internet connections

### 2. Server-Side
- Monitor concurrent connection limits
- Optimize database queries for client requests
- Implement proper load balancing for multiple instances

## Advanced Configuration

### 1. Custom Domains
- Set up DNS records pointing to your server IP
- Configure the client to use domain names instead of IP addresses
- Implement SSL certificates for secure connections

### 2. Multiple Server Instances
- Distribute client connections across multiple server instances
- Use load balancers for city and lot servers
- Implement shared NFS storage for consistent data

## Support Resources

- FreeSO Discord: For real-time support and community help
- GitHub Issues: For bug reports and technical issues
- Wiki Documentation: For detailed technical information

## Conclusion

Connecting clients to your FreeSO server requires careful coordination between the server setup and client configuration. The key steps involve obtaining the original game client, applying FreeSO patches, configuring connection endpoints, and ensuring network accessibility.

Remember that FreeSO is a complex system that replicates the original The Sims Online experience, so both server and client components must be properly configured for a successful connection.