#!/bin/sh

echo "Starting entrypoint..."

# 启动php-fpm
if [ "$1" = "nginx" ]; then
    php-fpm7
fi

exec "$@"