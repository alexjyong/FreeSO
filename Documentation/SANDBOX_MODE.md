# FreeSO Sandbox Mode

## Overview

FreeSO includes a sandbox mode that allows users to run the game without connecting to a full server infrastructure. This mode is particularly useful for:

- Testing game functionality without a full server setup
- Developing custom lots and objects
- Playing offline without network dependencies
- Debugging and development purposes

## How Sandbox Mode Works

Sandbox mode operates differently from the standard multiplayer server mode:

1. **Local-Only Operation**: Runs entirely on the local machine without external server connections
2. **Reduced External Dependencies**: Doesn't require a database connection for basic operation
3. **Self-Contained Simulation**: Contains its own SimAntics VM instance for lot/object simulation
4. **Still Requires Game Files**: Requires original TSO game files for core functionality, but may have more flexible requirements than server mode

## Enabling Sandbox Mode

### From the Client Interface

1. Launch the FreeSO client
2. Navigate to the main menu
3. Select "Sandbox Mode" option
4. The client will initialize a local-only game instance

### Through Configuration

Sandbox mode can also be enabled programmatically by launching the client with specific parameters or through the client's configuration settings.

## Features Available in Sandbox Mode

### 1. Lot Creation and Editing
- Create and modify lots without external server dependencies
- Place and manipulate objects freely
- Test lot designs before deployment to a server

### 2. Object Interaction
- Full object functionality within the local VM
- Test custom objects and behaviors
- Debug object interactions without network complexity

### 3. Sim Management
- Create and manage Sims in a local environment
- Test Sim behaviors and interactions
- Experiment with different Sim configurations

### 4. Development Tools
- Built-in debugging capabilities
- VM state inspection
- Performance profiling tools

### 5. Game Files Requirement
Even in sandbox mode, the FreeSO client still requires the original TSO game files to function. The client will look for these files in the locations specified by the `StartupPath` in the configuration or in the default search locations:
- `../The Sims Online/TSOClient/` (relative to the client executable)
- `game/TSOClient/` (for Linux systems)
- Windows registry location: `C:\Program Files\Maxis\The Sims Online\TSOClient\`

The client specifically looks for `tuning.dat` to verify the game installation.

### 6. NFS Data Requirement
Sandbox mode also requires an NFS (Network File System) directory for saving lot and object data. If you encounter errors like:
```
System.NullReferenceException: Object reference not set to an instance of an object.
at FSO.SimAntics.Utils.VMLotTerrainRestoreTools.RestoreSurroundings(VM vm, Byte hollowAdj)
```

This indicates that the NFS directory isn't properly configured or accessible. To fix this:

1. Create an NFS directory: `mkdir -p nfs`
2. Ensure the `simNFS` setting in your configuration points to this directory
3. Make sure the directory has proper read/write permissions
4. The NFS directory should contain subdirectories for lot/object saves

The client expects the NFS directory to be available at the location specified in the configuration (typically `./nfs` relative to the working directory).

## Limitations of Sandbox Mode

While sandbox mode is useful for development and testing, it has limitations compared to the full multiplayer experience:

1. **No Multiplayer**: Cannot connect with other players
2. **Limited Social Features**: No neighborhoods, city browsing, or social interactions
3. **No Persistence**: Changes may not persist between sessions depending on configuration
4. **Still Requires Game Files**: Needs original TSO game files for core functionality
5. **Reduced Content**: May not have access to all server-hosted content

## Technical Implementation

### Client-Side Components

The sandbox mode is implemented through several key components:

- `SandboxGameScreen.cs`: Main game screen for sandbox mode
- `FSOSandboxClient.cs` and `FSOSandboxServer.cs`: Local networking components
- `FSOSandboxProtocol.cs`: Communication protocol for sandbox operations
- `UISandboxSelector.cs`: UI for selecting sandbox lots

### Server-Side Components

The server includes sandbox-specific functionality:

- `FSOSandboxProtocol`: Protocol handling for sandbox mode
- `VMSandboxRestoreState`: State management for sandbox sessions
- `SandboxMode/BanList.cs`: Access control for sandbox environments

## Use Cases

### 1. Development and Testing
- Test new objects and behaviors
- Debug SimAntics scripts
- Prototype lot designs

### 2. Educational Purposes
- Learn about the game's architecture
- Understand object interactions
- Study SimAntics programming

### 3. Offline Play
- Play without internet connection
- Experiment with game mechanics
- Enjoy a simplified version of the game

## Configuration Options

Sandbox mode can be configured through the client's configuration system:

```json
{
  "sandboxMode": {
    "enabled": true,
    "localAssetsPath": "./sandbox_assets",
    "maxObjects": 1000,
    "debugMode": true
  }
}
```

## Troubleshooting

### Common Issues

#### Sandbox Mode Not Available
- Ensure you're using a client build that includes sandbox functionality
- Check that all required dependencies are installed

#### Performance Issues
- Reduce the number of objects in the lot
- Close other applications to free up resources
- Ensure sufficient RAM is allocated to the client

#### Asset Loading Problems
- Verify that required assets are available
- Check asset paths in the configuration
- Ensure proper file permissions

## Security Considerations

Sandbox mode runs entirely on the local machine and doesn't expose network services by default. However, when developing or testing, be aware that:

- Sandbox mode may have access to local file systems
- Debug features may expose more information than production mode
- Ensure proper isolation when testing untrusted content

## Comparison with Server Mode

| Feature | Sandbox Mode | Server Mode |
|---------|--------------|-------------|
| Multiplayer | ❌ No | ✅ Yes |
| Database | ❌ Not Required | ✅ Required |
| Original Game Files | ✅ Required* | ✅ Required |
| Persistence | ⚠️ Limited | ✅ Full |
| Social Features | ❌ No | ✅ Yes |
| Development Tools | ✅ Extensive | ⚠️ Limited |
| Performance | ✅ High | ⚠️ Variable |

*Both modes require original TSO game files, but sandbox mode may have more flexible requirements

## Getting Started

To begin using sandbox mode:

1. Launch the FreeSO client
2. Select "Sandbox Mode" from the main menu
3. Choose a local lot or create a new one
4. Begin experimenting with objects and Sims

## Advanced Usage

### Creating Custom Sandbox Lots

Sandbox mode supports loading custom lots from local files:

1. Create a lot file using the FreeSO lot editor
2. Save it to the appropriate local directory
3. Select it from the sandbox lot selector

### Integration with Server Development

Sandbox mode can be used to develop content that will later be deployed to a server:

1. Develop and test in sandbox mode
2. Export lot/blueprint files
3. Deploy to your FreeSO server
4. Test in multiplayer environment

## Conclusion

Sandbox mode provides a valuable development and testing environment for FreeSO. It allows users to experiment with the game mechanics without the complexity of a full server setup, making it ideal for developers, content creators, and casual users who want to explore the game's capabilities offline.