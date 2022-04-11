FROM php:7.4-fpm-alpine3.14

# 镜像说明
LABEL maintainer="edram"

# 配置阿里云镜像
RUN echo 'http://mirrors.aliyun.com/alpine/v3.14/main/' > /etc/apk/repositories \
    && echo 'http://mirrors.aliyun.com/alpine/v3.14/community/' >> /etc/apk/repositories

# composer
RUN apk add --no-cache curl
RUN curl https://mirrors.aliyun.com/composer/composer.phar -s -S -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
ENV PATH=/root/.composer/vendor/bin:$PATH

# 开发
RUN apk add --no-cache git nodejs npm

# Nginx
RUN apk add --no-cache nginx
# 配置拷贝到镜像中
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf


# 队列
RUN apk add --no-cache supervisor && \
    mkdir -p /var/log/supervisor
COPY config/supervisor/supervisord.conf /etc/supervisord.conf

# openssh
RUN apk add --no-cache openssh

# php
COPY ./scripts/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions \
        bcmath \
        gd \
        # mysql
        mysqli pdo_mysql \
        # sqlsrv
        sqlsrv pdo_sqlsrv \
        # queue
        pcntl \
    ;

# 拷贝入口脚本
COPY ./scripts/entrypoint.sh \
    /usr/local/bin/

# 指定入口
ENTRYPOINT ["entrypoint.sh"]

# 指定工作目录
WORKDIR /var/www/html

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisord.conf"]