#!/bin/sh

echo "Starting entrypoint..."

# 启动php-fpm
if [ "$1" = "supervisord" ]; then

fi

exec "$@"