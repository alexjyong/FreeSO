#!/bin/bash
# FreeSO Server Configuration Generator

set -e  # Exit on any error

echo "FreeSO Server Configuration Generator"
echo "====================================="

# Generate a random 64-character hex string for the secret
SECRET=$(openssl rand -hex 32)

# Get the current directory to suggest a default game location
DEFAULT_GAME_PATH="$(pwd)/game"
DEFAULT_NFS_PATH="$(pwd)/nfs_data"

echo ""
echo "This script will help you generate a basic config.json file for FreeSO."
echo ""

# Ask for game location
read -p "Enter the path to your TSO game files (default: $DEFAULT_GAME_PATH): " GAME_LOCATION
GAME_LOCATION=${GAME_LOCATION:-$DEFAULT_GAME_PATH}

# Ask for NFS location
read -p "Enter the path for NFS data (default: $DEFAULT_NFS_PATH): " SIM_NFS
SIM_NFS=${SIM_NFS:-$DEFAULT_NFS_PATH}

# Ask for database connection
read -p "Enter the database connection string (default: server=database;uid=fsoserver;pwd=password;database=fso;): " DB_CONNECTION
DB_CONNECTION=${DB_CONNECTION:-"server=database;uid=fsoserver;pwd=password;database=fso;"}

# Ask for server public host (for production, this would be your domain/IP)
read -p "Enter the public host for the API server (default: localhost): " PUBLIC_HOST
PUBLIC_HOST=${PUBLIC_HOST:-"localhost"}

echo ""
echo "Generating config.json..."

# Create the config.json file
cat > config.json << EOF
{
  "gameLocation": "$GAME_LOCATION",
  "secret": "$SECRET",
  "simNFS": "$SIM_NFS",

  "database": {
    "connectionString": "$DB_CONNECTION"
  },

  "services": {
    "tasks": {
      "enabled": true,
      "call_sign": "callisto",
      "binding": "0.0.0.0:35100",
      "internal_host": "127.0.0.1:35",
      "public_host": "$PUBLIC_HOST:35100"
    },
    "userApi": {
      "enabled": true,
      "bindings": [
        "http://+:9000/"
      ],
      "maintenance": false,
      "bindings_ssl": [],
      "cdnUrl": "http://$PUBLIC_HOST:9000",
      "updateUrl": "http://$PUBLIC_HOST:9000",
      "regkey": "",
      "smtpEnabled": false,
      "smtpHost": "",
      "smtpPort": 587,
      "smtpUser": "",
      "smtpPassword": ""
    },
    "cities": [
      {
        "call_sign": "ganymede",
        "id": 1,
        "binding": "0.0.0.0:33100",
        "internal_host": "127.0.0.1:33",
        "public_host": "$PUBLIC_HOST:33100"
      }
    ],
    "lots": [
      {
        "call_sign": "europa",
        "binding": "0.0.0.0:34100",
        "internal_host": "127.0.0.1:34",
        "public_host": "$PUBLIC_HOST:34100",
        "max_lots": 25,
        "cities": [
          {
            "id": 1,
            "host": "$PUBLIC_HOST:33100"
          }
        ]
      }
    ]
  }
}
EOF

echo ""
echo "Configuration file 'config.json' has been created!"
echo ""
echo "IMPORTANT NOTES:"
echo "- The secret key has been automatically generated"
echo "- You may need to adjust the public_host values for your specific setup"
echo "- For production, ensure your firewall allows traffic on ports 9000, 33100, 34100, 35100"
echo "- Make sure the gameLocation path contains your TSO game files"
echo "- The NFS path will store lot and object saves"
echo ""
echo "To run the server, execute: docker-compose -f docker-compose.prod.yml up -d"