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


# Split the PGDATABASE variable into an array using comma as the delimiter
IFS=',' read -ra DATABASES <<< "$PGDATABASE"

# Loop through the databases
for DATABASE in "${DATABASES[@]}"; do
    
    echo "backing up ${DATABASE}"

     # Create the directory for the current database if it doesn't exist
    mkdir -p "$BACKUP_DIR/${DATE}"

    # Set the backup file name for the current database
    BACKUP_FILE="$BACKUP_DIR/${DATE}/${DATABASE}.sql.gz"

    # Perform the pg_dump for the current database in correct order
    BACKUP_DIR_DB="$BACKUP_DIR/${DATE}/${DATABASE}"
    mkdir -p "$BACKUP_DIR_DB"

    echo "dumping pre-data"

    # Dump pre-data (schemas, types, etc.)
    PGPASSWORD=$PGPASSWORD pg_dump -U $PGUSER -h $PGHOST -p $PGPORT \
        --clean --if-exists --create --no-owner \
        --section=pre-data \
        $DATABASE | gzip > "$BACKUP_DIR_DB/01_pre_data.sql.gz"

    echo "dumping actual table contents"

    # Dump data (actual table contents)
    PGPASSWORD=$PGPASSWORD pg_dump -U $PGUSER -h $PGHOST -p $PGPORT \
        --column-inserts --rows-per-insert=5000 \
        --section=data \
        $DATABASE | gzip > "$BACKUP_DIR_DB/02_data.sql.gz"

    echo "dumping post-data"

    # Dump post-data (constraints, indexes, triggers)
    PGPASSWORD=$PGPASSWORD pg_dump -U $PGUSER -h $PGHOST -p $PGPORT \
        --section=post-data \
        $DATABASE | gzip > "$BACKUP_DIR_DB/03_post_data.sql.gz"

    # Check if the dump was successful
    if [ $? -eq 0 ]; then
      echo "Backup successful: $BACKUP_FILE"
    else
      echo "Backup failed for database $DATABASE"
      exit 1
    fi
done

echo "Uploading to minio"
# Upload the backup files to Google Drive using rclone
rclone --config=/config/rclone.conf -v copy $BACKUP_DIR minio:db-backups.davidson.house

# Check if the upload was successful
if [ $? -eq 0 ]; then
  echo "Upload successful"
else
  echo "Upload failed"
  exit 1
fi


# Ending Message
echo "Backup and upload completed successfully"
exit 0

