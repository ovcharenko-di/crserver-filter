FROM openresty/openresty:bionic

COPY ./lualib /usr/local/openresty/lualib/v8/

RUN rm /etc/nginx/conf.d/*.conf
COPY ./storage.conf /etc/nginx/conf.d
