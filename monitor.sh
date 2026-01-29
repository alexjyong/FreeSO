#!/bin/bash
# FreeSO Server Monitoring Script

set -e  # Exit on any error

echo "FreeSO Server Monitoring Dashboard"
echo "=================================="

# Check if Docker Compose is running
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "Error: docker-compose.prod.yml not found in current directory"
    exit 1
fi

echo ""
echo "Current Service Status:"
echo "======================="
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "Container Resource Usage:"
echo "========================="
docker-compose -f docker-compose.prod.yml top

echo ""
echo "Recent Logs (Last 20 lines per service):"
echo "========================================"

SERVICES=("freesoserver-prod" "freesodb-prod")
for service in "${SERVICES[@]}"; do
    echo ""
    echo ">>> $service <<<"
    if docker logs "$service" 2>/dev/null | tail -20; then
        echo "--- End of logs for $service ---"
    else
        echo "Service $service is not running or logs unavailable"
    fi
    echo ""
done

echo ""
echo "Disk Usage for Volumes:"
echo "======================="
docker volume ls --filter name=nfs_data --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || echo "nfs_data volume not found"
docker volume ls --filter name=db_data --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || echo "db_data volume not found"

echo ""
echo "Network Connections:"
echo "==================="
docker-compose -f docker-compose.prod.yml exec -T database mysql -u fsoserver -ppassword -e "SHOW PROCESSLIST;" 2>/dev/null || echo "Cannot connect to database to show process list"

echo ""
echo "Health Check Summary:"
echo "====================="
echo "Database: $(docker inspect --format='{{json .State.Health}}' freesodb-prod 2>/dev/null | grep -o '\"Status\":\"[^\"]*\"' | cut -d':' -f2 | tr -d '"')" 2>/dev/null || echo "Database: Not running"
echo "Server: $(docker inspect --format='{{json .State.Health}}' freesoserver-prod 2>/dev/null | grep -o '\"Status\":\"[^\"]*\"' | cut -d':' -f2 | tr -d '"')" 2>/dev/null || echo "Server: Not running"

echo ""
echo "Monitoring Tips:"
echo "- Watch for ERROR or EXCEPTION in logs"
echo "- Monitor CPU and memory usage"
echo "- Check that both services are running and healthy"
echo "- Verify that ports 9000, 33100, 34100, 35100 are accessible"
echo ""
echo "To continuously monitor: watch -n 5 './monitor.sh'"