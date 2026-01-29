# FreeSO Docker Troubleshooting Guide

This guide provides solutions for common issues when running FreeSO in Docker containers.

## Common Issues and Solutions

### 1. Build Failures

**Problem**: Docker build fails with .NET Framework compatibility errors
**Solution**: 
- Use the build script to compile on the host first: `./build-for-docker.sh`
- The Dockerfile is designed to work with pre-built binaries
- If building directly in Docker, ensure you're using the development Dockerfile

### 2. Database Connection Issues

**Problem**: Server cannot connect to the database
**Symptoms**: 
- Error messages about database connection failure
- Server fails to start

**Solutions**:
1. Check if the database container is running:
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   ```
2. Verify database logs:
   ```bash
   docker-compose -f docker-compose.prod.yml logs database
   ```
3. Check database connectivity:
   ```bash
   docker-compose -f docker-compose.prod.yml exec database mysql -u fsoserver -ppassword -e "SELECT 1;"
   ```
4. Ensure the connection string in config.json matches the database service name

### 3. Port Binding Issues

**Problem**: Cannot access the server on expected ports
**Symptoms**:
- Connection refused when accessing ports 9000, 33100, 34100, 35100
- Firewall blocking access

**Solutions**:
1. Check if ports are bound correctly:
   ```bash
   docker port freesoserver-prod
   ```
2. Verify firewall settings allow access to these ports
3. Check if other services are using the same ports:
   ```bash
   sudo netstat -tulpn | grep -E ':9000|:33100|:34100|:35100'
   ```

### 4. Game Files Not Found

**Problem**: Server reports missing game files
**Symptoms**:
- Error messages about missing tuning.dat or other game files
- Server fails to start

**Solutions**:
1. Verify game files are mounted correctly:
   ```bash
   docker-compose -f docker-compose.prod.yml exec server ls -la /game
   ```
2. Check that the gameLocation in config.json matches the mounted path
3. Ensure the game files directory contains the required TSO files (tuning.dat, TSOClient/, etc.)

### 5. NFS Data Issues

**Problem**: Lot/object saves not persisting
**Symptoms**:
- Data lost after container restart
- NFS-related errors in logs

**Solutions**:
1. Check NFS volume:
   ```bash
   docker volume ls | grep nfs_data
   ```
2. Verify NFS directory permissions:
   ```bash
   docker-compose -f docker-compose.prod.yml exec server ls -la /nfs
   ```
3. Ensure the NFS path in config.json matches the mounted path

### 6. Health Check Failures

**Problem**: Containers showing as unhealthy
**Symptoms**:
- `docker-compose ps` shows "unhealthy" status

**Solutions**:
1. Check health check logs:
   ```bash
   docker inspect freesoserver-prod | grep -A 10 "Health"
   ```
2. Verify the application is responding to health checks
3. Check if the server is listening on the expected ports

### 7. Memory Issues

**Problem**: Container crashes due to memory exhaustion
**Symptoms**:
- Out of memory (OOM) errors
- Container restarts unexpectedly

**Solutions**:
1. Increase memory limits in docker-compose.prod.yml:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 4G  # Increase as needed
   ```
2. Monitor memory usage:
   ```bash
   docker stats freesoserver-prod
   ```

## Diagnostic Commands

### Check Overall System Status
```bash
docker-compose -f docker-compose.prod.yml ps
```

### View Recent Logs
```bash
docker-compose -f docker-compose.prod.yml logs --tail=50 server
docker-compose -f docker-compose.prod.yml logs --tail=50 database
```

### Check Resource Usage
```bash
docker stats --no-stream
```

### Connect to Server Container
```bash
docker-compose -f docker-compose.prod.yml exec server bash
```

### Connect to Database
```bash
docker-compose -f docker-compose.prod.yml exec database mysql -u fsoserver -ppassword fso
```

### Test Database Connectivity from Server
```bash
docker-compose -f docker-compose.prod.yml exec server nc -zv database 3306
```

## Performance Tuning

### Database Optimization
- Ensure sufficient memory allocation for MariaDB
- Monitor slow queries and optimize as needed
- Consider using persistent volumes for better I/O performance

### Server Optimization
- Adjust .NET runtime settings if needed
- Monitor GC pressure and tune accordingly
- Consider resource limits to prevent resource contention

## Security Considerations

### Secrets Management
- Never commit passwords to version control
- Use Docker secrets for sensitive data
- Rotate passwords regularly

### Network Security
- Use Docker networks for service isolation
- Restrict external port exposure
- Consider using a reverse proxy for additional security

### Container Security
- Run containers as non-root users
- Use minimal base images
- Keep images updated with security patches

## Recovery Procedures

### From Backup
1. Stop the services: `docker-compose -f docker-compose.prod.yml down`
2. Restore database: `docker exec -i <container_id> mysql -u fsoserver -ppassword fso < backup.sql`
3. Restore NFS data to the volume
4. Start services: `docker-compose -f docker-compose.prod.yml up -d`

### Rollback
1. Stop current services
2. Revert to previous image version
3. Start services with previous configuration