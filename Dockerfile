FROM alpine:3.13

# 镜像说明
LABEL maintainer="edram"

# 配置阿里云镜像
RUN echo 'http://mirrors.aliyun.com/alpine/v3.13/main/' > /etc/apk/repositories \
    && echo 'http://mirrors.aliyun.com/alpine/v3.13/community/' >> /etc/apk/repositories

# 依赖
RUN apk add --no-cache \
        #- base
        php7 \
        #- laravel/framework (官网列着的)
        php7-bcmath php7-ctype php7-fileinfo php7-json php7-mbstring php7-openssl php7-tokenizer php7-xml \
        #- laravel
        php7-dom php7-iconv \
        #- gd
        php7-gd \
        #- phpunit (dev)
        php7-xmlwriter \
        #- composer(开发所需)
        php7-phar \
        #- mysql
        php7-mysqli php7-pdo_mysql \
        #- redis
        php7-redis \
        #- zip
        php7-zip \
        #- curl
        php7-curl \
        #- 额外
        php7-simplexml php7-pcntl

# composer
RUN apk add --no-cache curl
RUN curl https://mirrors.aliyun.com/composer/composer.phar -s -S -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
RUN  composer global require overtrue/package-builder
ENV PATH=/root/.composer/vendor/bin:$PATH

# 开发
RUN apk add --no-cache git nodejs npm

# FPM
# FPM 所需用户和用户组 
# https://github.com/docker-library/php/blob/master/7.4/alpine3.11/fpm/Dockerfile#L31
RUN set -eux; \
    addgroup -g 82 -S www-data; \
    adduser -u 82 -D -S -G www-data www-data

RUN apk add --no-cache php7-fpm
# 拷贝php-fpm配置
COPY config/php-fpm/php-fpm.conf /etc/php7/php-fpm.conf

# Nginx
RUN apk add --no-cache nginx
# 配置拷贝到镜像中
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf

# 队列
RUN apk add --no-cache supervisor && \
    mkdir -p /var/log/supervisor
COPY config/supervisor/supervisord.conf /etc/supervisord.conf

# openssh
RUN apk add --no-cache openssh \
  # 允许 root 登录
  && sed -i "s/#PermitRootLogin.*/PermitRootLogin\ yes/" /etc/ssh/sshd_config \
  && sed -i "s/AllowTcpForwarding.*/AllowTcpForwarding\ yes/" /etc/ssh/sshd_config \
  && echo "root:123456" | chpasswd

# 拷贝入口脚本
COPY ./scripts/entrypoint.sh \
    /usr/local/bin/

# 指定入口
ENTRYPOINT ["entrypoint.sh"]

# 指定工作目录
WORKDIR /var/www/html

EXPOSE 80 22

CMD ["supervisord", "-c", "/etc/supervisord.conf"]