FROM php:7.4-fpm-alpine3.14

# 镜像说明
LABEL maintainer="edram"

# 配置阿里云镜像
RUN echo 'http://mirrors.aliyun.com/alpine/v3.13/main/' > /etc/apk/repositories \
    && echo 'http://mirrors.aliyun.com/alpine/v3.13/community/' >> /etc/apk/repositories

# composer
RUN apk add --no-cache curl
RUN curl https://mirrors.aliyun.com/composer/composer.phar -s -S -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
RUN  composer global require overtrue/package-builder
ENV PATH=/root/.composer/vendor/bin:$PATH

# Nginx
RUN apk add --no-cache nginx
# 配置拷贝到镜像中
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf


# 队列
RUN apk add --no-cache supervisor && \
    mkdir -p /var/log/supervisor
COPY config/supervisor/supervisord.conf /etc/supervisord.conf

EXPOSE 80 22

CMD [nginx -g 'daemon off;']