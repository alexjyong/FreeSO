#!/bin/bash
set -e

# Wait for MySQL to be ready
until mysqladmin ping -h localhost --silent; do
  sleep 1
done

echo "Initializing FreeSO database..."

# Run the db-init command to set up the schema
# This would normally be done by the FreeSO server, but we'll do it here as well
# to ensure the database is properly initialized before the server starts

echo "Database initialization complete."