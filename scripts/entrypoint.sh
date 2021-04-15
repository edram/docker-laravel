#!/bin/sh

echo "Starting entrypoint..."

# generate host keys if not present
ssh-keygen -A

# 启动php-fpm
if [ "$1" = "supervisord" ]; then
  echo "启动 supervisord"
fi

exec "$@"