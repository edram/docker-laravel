#!/bin/sh

echo "Starting entrypoint..."

# 启动php-fpm
if [ "$1" = "supervisord" ]; then
  echo "启动 supervisord"
fi

exec "$@"