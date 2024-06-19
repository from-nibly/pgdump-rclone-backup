#!/bin/bash

# Setting up the variables
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="/app/backups"

# Starting Message
echo "Starting Backup at $DATE"

# Create the backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Check if the PGPASSWORD variable is set
if [ -z "$PGPASSWORD" ]; then
  echo "The PGPASSWORD environment variable is not set. Exiting..."
  exit 1
fi

# Check if the PGUSER variable is set
if [ -z "$PGUSER" ]; then
  echo "The PGUSER environment variable is not set. Exiting..."
  exit 1
fi

# Check if the PGHOST variable is set
if [ -z "$PGHOST" ]; then
  echo "The PGHOST environment variable is not set. Exiting..."
  exit 1
fi

# Check if the PGPORT variable is set
if [ -z "$PGPORT" ]; then
  echo "The PGPORT environment variable is not set. Exiting..."
  exit 1
fi

# Check if the PGDATABASE variable is set
if [ -z "$PGDATABASE" ]; then
  echo "The PGDATABASE environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$GDRIVE_CLIENT_ID" ]; then
  echo "The GDRIVE_CLIENT_ID environment variable is not set. Exiting..."
  exit 1
fi

if [ -z "$GDRIVE_CLIENT_SECRET" ]; then
    echo "The GDRIVE_CLIENT_SECRET environment variable is not set. Exiting..."
    exit 1
fi

if [ -z "$GDRIVE_TOKEN" ]; then
    echo "The GDRIVE_TOKEN environment variable is not set. Exiting..."
    exit 1
fi

if [ -z "$RCLONE_REMOTE_NAME" ]; then
    echo "The RCLONE_REMOTE_NAME environment variable is not set. Exiting..."
    exit 1
fi

if [ -z "$RCLONE_REMOTE_PATH" ]; then
    echo "The RCLONE_REMOTE_PATH environment variable is not set. Exiting..."
    exit 1
fi

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
rclone copy $BACKUP_DIR $RCLONE_REMOTE_NAME:$RCLONE_REMOTE_PATH

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

