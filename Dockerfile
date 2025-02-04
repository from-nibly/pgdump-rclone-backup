# Use the official PostgreSQL image from the Docker Hub
FROM --platform=linux/amd64 postgres:15-alpine

# Install required tools
RUN apk add --no-cache \
    curl \
    unzip \
    gzip \
    bash

# Install rclone
RUN curl https://rclone.org/install.sh | bash

# Copy the backup script into the image
COPY backup_pg.sh /backup_pg.sh

ENV TZ='America/Denver' 

# Make the backup script executable
RUN chmod +x /backup_pg.sh

# Run the backup script
CMD ["/backup_pg.sh"]
