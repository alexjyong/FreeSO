# Testing Your FreeSO Server

This document provides comprehensive guidance on testing your FreeSO server to ensure it's properly configured and running.

## Overview

Testing your FreeSO server involves verifying that all services are running correctly, responding to requests, and properly handling client connections. This document covers both automated and manual testing approaches.

## Prerequisites for Testing

Before testing your server, ensure:
- The FreeSO server is running (via Docker or directly)
- All required ports are accessible (9000, 33100, 34100, 35100)
- The database is properly connected and initialized
- Game files are accessible to the server
- Network connectivity is available between client and server

## Automated Testing Methods

### 1. Using the Monitoring Script

FreeSO includes a monitoring script that provides a comprehensive status overview:

```bash
chmod +x Docker/monitor.sh
./Docker/monitor.sh
```

This script will:
- Check the status of all Docker services
- Display resource usage
- Show recent logs
- Verify service health

### 2. Health Check Endpoints

The FreeSO server exposes health check endpoints:

```bash
# Check API server health
curl -v http://your-server-ip:9000/api/health

# Check if the main server process is responding
curl -v http://your-server-ip:9000/api/status
```

### 3. Docker Compose Status Check

Check the status of all services:
```bash
docker-compose -f Docker/docker-compose.yml ps
```

Verify service logs:
```bash
docker-compose -f Docker/docker-compose.yml logs server
docker-compose -f Docker/docker-compose.yml logs database
```

## Manual Testing Procedures

### 1. API Endpoint Testing

Test the main API endpoints:

```bash
# Test user API
curl -X GET http://your-server-ip:9000/api/users

# Test city server connectivity (if accessible)
telnet your-server-ip 33100

# Test lot server connectivity (if accessible)
telnet your-server-ip 34100

# Test task server connectivity (if accessible)
telnet your-server-ip 35100
```

### 2. Database Connectivity Test

Verify that the server can connect to the database:

```bash
# Check if database is accessible from server container
docker-compose -f Docker/docker-compose.yml exec server nc -zv database 3306

# Test database connection manually
docker-compose -f Docker/docker-compose.yml exec server mysql -h database -u fsoserver -ppassword -e "SELECT 1;" fso
```

### 3. Game File Access Test

Verify that the server can access the required game files:

```bash
# Check if game files are accessible from the server container
docker-compose -f Docker/docker-compose.yml exec server ls -la /game/

# Verify critical game files exist
docker-compose -f Docker/docker-compose.yml exec server ls -la /game/tuning.dat
docker-compose -f Docker/docker-compose.yml exec server ls -la /game/TSOClient/
```

## Client Connection Testing

### 1. Prerequisites for Client Testing

Before testing client connections:
- Ensure you have a properly patched TSO client
- Verify the client configuration points to your server
- Confirm all required ports are accessible from the client machine
- Ensure you have created test accounts on your server

### 2. Basic Connection Test

1. Start the patched TSO client
2. Attempt to log in with a test account
3. Monitor server logs for connection attempts:
   ```bash
   docker-compose -f Docker/docker-compose.yml logs -f server
   ```

4. Look for successful authentication messages in the logs

### 3. Functional Testing

Once connected, test the following functionalities:
- Character creation
- Neighborhood navigation
- Lot entry and exit
- Object placement and interaction
- Chat and social features
- Inventory management

## Network Testing

### 1. Port Accessibility

Verify that all required ports are accessible:

```bash
# Test API port
nmap -p 9000 your-server-ip

# Test city server port
nmap -p 33100 your-server-ip

# Test lot server port
nmap -p 34100 your-server-ip

# Test task server port
nmap -p 35100 your-server-ip
```

### 2. Firewall Configuration

Ensure your firewall allows traffic on the required ports:
- 9000: API server
- 33100: City server
- 34100: Lot server
- 35100: Task server

## Performance Testing

### 1. Load Testing

Simulate multiple concurrent connections:
- Use multiple client instances if available
- Monitor server resource usage during load
- Check for stability under sustained load

### 2. Resource Monitoring

Monitor server resources:
```bash
# Monitor Docker container resource usage
docker stats --no-stream

# Monitor continuously
docker stats
```

### 3. Response Time Testing

Test response times for various operations:
- Login requests
- City navigation
- Lot loading
- Object interactions

## Troubleshooting Common Issues

### 1. Service Not Starting

If services fail to start:
```bash
# Check detailed logs
docker-compose -f Docker/docker-compose.yml logs --tail=100 server

# Check if database is ready before server starts
docker-compose -f Docker/docker-compose.yml logs database
```

### 2. Database Connection Issues

If the server can't connect to the database:
- Verify database service is running
- Check database credentials in config.json
- Confirm network connectivity between containers

### 3. Game Files Not Found

If the server reports missing game files:
- Verify the game files directory is properly mounted
- Check file permissions
- Confirm the paths in config.json are correct

### 4. Client Connection Failures

If clients can't connect:
- Verify all ports are accessible
- Check client configuration files
- Confirm server IP addresses are correct in client config

## Automated Testing Script

Create a comprehensive testing script:

```bash
#!/bin/bash
# server-test.sh - Automated server testing script

echo "FreeSO Server Testing Script"
echo "============================"

# Test 1: Check if services are running
echo "Test 1: Checking service status..."
SERVER_STATUS=$(docker-compose -f Docker/docker-compose.yml ps server 2>/dev/null | grep -c "Up")
DB_STATUS=$(docker-compose -f Docker/docker-compose.yml ps database 2>/dev/null | grep -c "Up")

if [ "$SERVER_STATUS" -gt 0 ] && [ "$DB_STATUS" -gt 0 ]; then
    echo "✓ Services are running"
else
    echo "✗ Services are not running properly"
    exit 1
fi

# Test 2: Check API endpoint
echo "Test 2: Testing API endpoint..."
if curl -s --connect-timeout 5 http://localhost:9000/api/health > /dev/null; then
    echo "✓ API endpoint is responsive"
else
    echo "✗ API endpoint is not responsive"
fi

# Test 3: Check database connectivity
echo "Test 3: Testing database connectivity..."
if docker-compose -f Docker/docker-compose.yml exec server nc -z database 3306 2>/dev/null; then
    echo "✓ Database connectivity OK"
else
    echo "✗ Database connectivity failed"
fi

# Test 4: Check game files
echo "Test 4: Checking game files..."
if docker-compose -f Docker/docker-compose.yml exec server test -f /game/tuning.dat 2>/dev/null; then
    echo "✓ Critical game files found"
else
    echo "✗ Critical game files missing"
fi

echo "Testing complete!"
```

## Monitoring and Logging

### 1. Log Analysis

Monitor logs for errors and warnings:
```bash
# View recent server logs
docker-compose -f Docker/docker-compose.yml logs --tail=50 server

# Follow logs in real-time
docker-compose -f Docker/docker-compose.yml logs -f server
```

### 2. Performance Metrics

Track performance metrics:
- CPU and memory usage
- Network throughput
- Database query performance
- Client connection counts

## Backup and Recovery Testing

### 1. Test Backup Procedures

Verify that your backup procedures work:
```bash
# Run backup script
chmod +x Docker/backup.sh
./Docker/backup.sh
```

### 2. Recovery Testing

Test your recovery procedures periodically:
- Restore from a backup
- Verify data integrity
- Confirm services start correctly

## Security Testing

### 1. Access Control

Verify that only authorized users can access the server:
- Test authentication mechanisms
- Verify account restrictions
- Check for unauthorized access attempts

### 2. Network Security

Test network security:
- Verify that unnecessary ports are closed
- Check for proper encryption where required
- Monitor for suspicious activities

## Conclusion

Regular testing of your FreeSO server is essential for maintaining a stable and enjoyable gaming experience. This document provides a comprehensive approach to testing, from basic service verification to advanced performance and security testing.

Remember to:
- Test regularly, especially after updates
- Monitor logs for potential issues
- Maintain backup procedures
- Verify client connectivity periodically
- Document any issues and resolutions for future reference

For additional support, consult the FreeSO community resources or refer to the detailed documentation in the main FreeSO repository.