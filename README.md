# Dockerized Backup

This is a simple docker image to backup postgres databases. It uses pg_dump to backup the databases. And backup files are uploaded to google drive using rclone.

## Usage

1. Clone the repository

   ```bash
   git clone
   ```

2. Configure rclone. You can follow the instructions [here](https://rclone.org/drive/).

3. Build the image

   ```bash
   docker build -t dockerized-backup .
   ```

4. Create a `.env` file with the following environment variables.

   ```bash
   PGPASSWORD=postgres
   PGDATABASE=postgres
   PGHOST=host.docker.internal
   PGPORT=5432
   PGUSER=postgres
   GDRIVE_CLIENT_ID=
   GDRIVE_CLIENT_SECRET=
   GDRIVE_TOKEN=
   ```

5. Run the image with environment variables

   ```bash
   docker run --env-file .env dockerized-backup
   ```
