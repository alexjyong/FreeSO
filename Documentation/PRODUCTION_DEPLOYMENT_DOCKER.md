# FreeSO Docker Production Deployment Guide

## Overview

This guide provides a complete solution for deploying the FreeSO server in production using Docker containers. The solution addresses the challenges of the FreeSO codebase while providing a robust, scalable, and secure deployment.

## Architecture

The production setup consists of:
- **FreeSO Server**: Runs the main game server application
- **MariaDB Database**: Stores user data, game state, and other persistent information
- **Persistent Volumes**: For NFS data and database storage
- **Secure Networking**: Isolated network with proper service dependencies

## Prerequisites

- Docker Engine 20.10+
- Docker Compose v2+
- .NET SDK 9.0 (for building on host)
- Original The Sims Online game files
- At least 4GB RAM allocated to Docker
- Linux-based host system (for optimal performance)

## Production Deployment Steps

### 1. Prepare the Environment
```bash
# Clone the repository
git clone <repository-url>
cd FreeSO

# Ensure you have the original TSO game files
mkdir -p game
# Copy TSO game files to the 'game' directory
```

### 2. Build the Application
```bash
chmod +x build-for-docker.sh
./build-for-docker.sh
```

### 3. Configure the Server
```bash
chmod +x setup-config.sh
./setup-config.sh
# Follow the prompts to generate config.json
```

### 4. Set Up Security
```bash
# Create secrets directory
mkdir -p secrets

# Create secure passwords (replace with your own secure passwords)
echo "your_secure_root_password" > secrets/db_root_password.txt
echo "your_secure_user_password" > secrets/db_password.txt
```

### 5. Deploy the Services
```bash
# Make the deployment script executable
chmod +x Docker/deploy-prod.sh

# Run the deployment
./Docker/deploy-prod.sh
```

### 6. Verify the Deployment
```bash
# Check service status
docker-compose -f Docker/docker-compose.prod.yml ps

# Check logs
docker-compose -f Docker/docker-compose.prod.yml logs server
```

## Production Operations

### Monitoring
```bash
# Run the monitoring script
chmod +x monitor.sh
./monitor.sh

# Continuous monitoring
watch -n 5 './monitor.sh'
```

### Backups
```bash
# Create a backup
chmod +x backup.sh
./backup.sh
```

### Maintenance
- Regularly update Docker images
- Monitor resource usage
- Check logs for errors
- Perform regular backups
- Update security patches

## Scaling Considerations

The FreeSO server architecture supports horizontal scaling:
1. Multiple server instances behind a load balancer
2. Shared NFS storage for consistent lot/object data
3. Centralized database for user and game state
4. Proper session management for client connections

For high availability, consider:
- Running multiple instances behind a load balancer
- Database replication for redundancy
- Backup and disaster recovery procedures

## Security Best Practices

1. **Secrets Management**: Use Docker secrets for sensitive data
2. **Non-Root Execution**: Run containers as non-root users
3. **Resource Limits**: Set appropriate resource limits
4. **Network Isolation**: Use isolated networks
5. **Regular Updates**: Keep images and dependencies updated
6. **Access Control**: Restrict access to management interfaces

## Troubleshooting

Refer to `TROUBLESHOOTING.md` for common issues and solutions.

## Production Checklist

- [ ] Secure passwords for database credentials
- [ ] SSL/TLS configuration for API server
- [ ] Firewall rules configured
- [ ] Regular backup procedures established
- [ ] Monitoring and alerting set up
- [ ] Resource limits configured
- [ ] Health checks verified
- [ ] Security scanning implemented
- [ ] Logging aggregation configured
- [ ] Disaster recovery procedures tested

## Support and Maintenance

### Daily Operations
- Monitor service health
- Check logs for errors
- Verify backup completion
- Monitor resource usage

### Weekly Operations
- Review security logs
- Update Docker images if needed
- Check disk space on volumes
- Verify backup integrity

### Monthly Operations
- Test disaster recovery procedures
- Review and rotate secrets
- Update documentation
- Review performance metrics

## Conclusion

This production-ready Docker deployment provides a solid foundation for running FreeSO servers. The solution addresses the technical challenges of the FreeSO codebase while providing enterprise-grade features like security, monitoring, and scalability.

Remember to regularly update and maintain your deployment to ensure optimal performance and security.