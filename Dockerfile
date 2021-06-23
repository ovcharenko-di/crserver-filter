FROM openresty/openresty:bionic

RUN apt-get update && apt-get install -y \
    git \
    libssl-dev \
    pcre2-utils \
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/openresty/luajit/bin/luarocks install lrexlib-pcre \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-http \
    && /usr/local/openresty/luajit/bin/luarocks install telegram-bot-lua

LABEL maintainer="Dima Ovcharenko <d.ovcharenko90@gmail.com>"
