#!/bin/bash
# FreeSO Server Backup Script

set -e  # Exit on any error

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./backups/$TIMESTAMP"
LOG_FILE="$BACKUP_DIR/backup.log"

echo "FreeSO Server Backup Script"
echo "==========================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_message "Starting FreeSO backup process"

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    log_message "Error: Docker Compose is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "docker-compose.prod.yml" ]; then
    log_message "Error: docker-compose.prod.yml not found in current directory"
    exit 1
fi

# Check if services are running
if ! docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
    log_message "Warning: Services may not be running. Proceeding with backup anyway."
fi

# Stop the server temporarily for consistent NFS backup
log_message "Stopping FreeSO server temporarily for consistent NFS backup..."
docker-compose -f docker-compose.prod.yml stop server

# Create database backup
log_message "Creating database backup..."
DB_CONTAINER=$(docker-compose -f docker-compose.prod.yml ps -q database)
if [ -n "$DB_CONTAINER" ]; then
    docker exec "$DB_CONTAINER" mysqldump -u fsoserver -ppassword fso > "$BACKUP_DIR/database_backup_$TIMESTAMP.sql"
    log_message "Database backup completed"
else
    log_message "Error: Could not find database container"
fi

# Create NFS data backup
log_message "Creating NFS data backup..."
NFS_VOLUME=$(docker volume ls -q | grep "nfs_data")
if [ -n "$NFS_VOLUME" ]; then
    # Create a temporary container to access the volume
    TEMP_CONTAINER=$(docker create -v "$NFS_VOLUME":/nfs alpine:latest)
    docker cp "$TEMP_CONTAINER:/nfs" "$BACKUP_DIR/nfs_data"
    docker rm -v "$TEMP_CONTAINER" > /dev/null 2>&1
    log_message "NFS data backup completed"
else
    log_message "Warning: Could not find nfs_data volume"
fi

# Restart the server
log_message "Restarting FreeSO server..."
docker-compose -f docker-compose.prod.yml start server

# Create configuration backup
log_message "Creating configuration backup..."
cp config.json "$BACKUP_DIR/config.json" 2>/dev/null || log_message "Warning: config.json not found, skipping config backup"

# Create secrets backup (optional - be careful with this)
read -p "Include secrets in backup? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_message "Creating secrets backup..."
    mkdir -p "$BACKUP_DIR/secrets"
    cp -r secrets/* "$BACKUP_DIR/secrets/" 2>/dev/null || log_message "Warning: No secrets directory found"
fi

# Create a backup manifest
cat > "$BACKUP_DIR/manifest.txt" << EOF
FreeSO Server Backup Manifest
=============================

Timestamp: $TIMESTAMP
Hostname: $(hostname)
Backup Directory: $BACKUP_DIR

Contents:
- Database dump: database_backup_$TIMESTAMP.sql
- NFS data: nfs_data/
- Configuration: config.json
- Secrets: secrets/ (if included)

EOF

log_message "Backup completed successfully!"
log_message "Backup location: $BACKUP_DIR"
log_message "Total backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"

echo ""
echo "Backup completed!"
echo "Location: $BACKUP_DIR"
echo ""
echo "To restore this backup, you will need to:"
echo "1. Stop the FreeSO server"
echo "2. Restore the database: docker exec -i <db_container> mysql -u fsoserver -ppassword fso < database_backup_YYYYMMDD_HHMMSS.sql"
echo "3. Restore NFS data to the nfs_data volume"
echo "4. Replace config.json if needed"
echo "5. Start the server"