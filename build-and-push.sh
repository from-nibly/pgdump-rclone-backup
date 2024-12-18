docker buildx build --platform linux/amd64 \
  -t kingteza/pgdump_rclone_backup:latest \
  --push .