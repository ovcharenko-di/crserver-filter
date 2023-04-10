FROM openresty/openresty:xenial

RUN apt-get update && apt-get install -y \
    git \
    libssl-dev \
    libpcre3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN /usr/local/openresty/luajit/bin/luarocks install lrexlib-pcre
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http 
RUN /usr/local/openresty/luajit/bin/luarocks install lua-cjson

LABEL maintainer="Ivanov Egor"