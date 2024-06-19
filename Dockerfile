# Use the official PostgreSQL image from the Docker Hub
FROM postgres:latest

# Install curl and cron (if needed)
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Copy the backup script into the image
COPY backup_pg.sh /backup_pg.sh
COPY rclone.conf /root/.config/rclone/rclone.conf

ENV TZ='Asia/Kolkata' 

# Make the backup script executable
RUN chmod +x /backup_pg.sh

# Run the backup script
CMD ["/backup_pg.sh"]
