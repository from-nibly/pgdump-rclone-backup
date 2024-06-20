#!/bin/bash

# Setting up the variables
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/app/backups"

# Starting Message
echo "Starting Backup at $DATE"

# Create the backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Check environment variables are correctly set.

if [ -z "$PGPASSWORD" ]; then
  echo "The PGPASSWORD environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$PGUSER" ]; then
  echo "The PGUSER environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$PGHOST" ]; then
  echo "The PGHOST environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$PGPORT" ]; then
  echo "The PGPORT environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$PGDATABASE" ]; then
  echo "The PGDATABASE environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$RCLONE_REMOTE_PATH" ]; then
  echo "The RCLONE_REMOTE_PATH environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$RCLONE_CONFIG_DB_BACKUPS_TYPE" ]; then
  echo "The RCLONE_CONFIG_DB_BACKUPS_TYPE environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$RCLONE_CONFIG_DB_BACKUPS_CLIENT_ID" ]; then
  echo "The RCLONE_CONFIG_DB_BACKUPS_CLIENT_ID environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$RCLONE_CONFIG_DB_BACKUPS_CLIENT_SECRET" ]; then
  echo "The RCLONE_CONFIG_DB_BACKUPS_CLIENT_SECRET environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$RCLONE_CONFIG_DB_BACKUPS_SCOPE" ]; then
  echo "The RCLONE_CONFIG_DB_BACKUPS_SCOPE environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$RCLONE_CONFIG_DB_BACKUPS_TOKEN" ]; then
  echo "The RCLONE_CONFIG_DB_BACKUPS_TOKEN environment variable is not set. Exiting..."
  exit 1
fi

export RCLONE_CONFIG_DB_BACKUPS_TYPE=$RCLONE_CONFIG_DB_BACKUPS_TYPE
export RCLONE_CONFIG_DB_BACKUPS_CLIENT_ID=$RCLONE_CONFIG_DB_BACKUPS_CLIENT_ID
export RCLONE_CONFIG_DB_BACKUPS_CLIENT_SECRET=$RCLONE_CONFIG_DB_BACKUPS_CLIENT_SECRET
export RCLONE_CONFIG_DB_BACKUPS_SCOPE=$RCLONE_CONFIG_DB_BACKUPS_SCOPE
export RCLONE_CONFIG_DB_BACKUPS_TOKEN=$RCLONE_CONFIG_DB_BACKUPS_TOKEN
export RCLONE_CONFIG_DB_BACKUPS_TEAM_DRIVE=


# Split the PGDATABASE variable into an array using comma as the delimiter
IFS=',' read -ra DATABASES <<< "$PGDATABASE"

# Loop through the databases
for DATABASE in "${DATABASES[@]}"; do
     # Create the directory for the current database if it doesn't exist
    mkdir -p "$BACKUP_DIR/${DATE}"

    # Set the backup file name for the current database
    BACKUP_FILE="$BACKUP_DIR/${DATE}/${DATABASE}.sql.gz"

    # Perform the pg_dump for the current database
    PGPASSWORD=$PGPASSWORD pg_dump -U $PGUSER -h $PGHOST -p $PGPORT --disable-triggers $DATABASE | gzip > $BACKUP_FILE

    # Check if the dump was successful
    if [ $? -eq 0 ]; then
      echo "Backup successful: $BACKUP_FILE"
    else
      echo "Backup failed for database $DATABASE"
      exit 1
    fi
done

# Upload the backup files to Google Drive using rclone
rclone copy $BACKUP_DIR db_backups:$RCLONE_REMOTE_PATH

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "Upload successful"
else
  echo "Upload failed"
  exit 1
fi

# Cleanup the backup directory
rm -rf $BACKUP_DIR

# Check if the cleanup was successful
if [ $? -eq 0 ]; then
  echo "Cleanup successful"
else
  echo "Cleanup failed"
  exit 1
fi

# Ending Message
echo "Backup and upload completed successfully"
exit 0

