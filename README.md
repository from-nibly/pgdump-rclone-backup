# Dockerized Backup

This is a simple docker image to backup postgres databases. It uses pg_dump to backup the databases. And backup files are uploaded to google drive using rclone.

## Usage

1. Clone the repository

   ```bash
   git clone
   ```

2. Configure rclone. You can follow the instructions [here](https://rclone.org/drive/). When you configure rclone, use `db-backups` as the remote name. If you want to use a different name, you need to update backup.sh file and environment variables like `RCLONE_CONFIG_YOUR_NAME_TYPE` in the `.env` file.

3. Build the image

   ```bash
   docker build -t dockerized-backup .
   ```

4. Create a `.env` file with the following environment variables.

   ```bash
   PGPASSWORD=
   PGUSER=
   PGHOST=
   PGPORT=
   PGDATABASE=

   RCLONE_REMOTE_PATH= # Folder/filepath You want to save the backups in google drive
   RCLONE_CONFIG_DB_BACKUPS_TYPE=
   RCLONE_CONFIG_DB_BACKUPS_CLIENT_ID=
   RCLONE_CONFIG_DB_BACKUPS_CLIENT_SECRET=
   RCLONE_CONFIG_DB_BACKUPS_SCOPE=
   RCLONE_CONFIG_DB_BACKUPS_TOKEN=
   ```

5. Run the image with environment variables

   ```bash
   docker run --env-file .env dockerized-backup
   ```
