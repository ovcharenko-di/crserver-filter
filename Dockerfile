FROM openresty/openresty

LABEL maintainer="Dima Ovcharenko <d.ovcharenko90@gmail.com>"

RUN /usr/local/openresty/luajit/bin/luarocks install lrexlib-PCRE