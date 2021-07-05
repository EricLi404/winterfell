FROM centos:8
MAINTAINER EricLi404 <ericli404@hotmail.com>

RUN yum install wget pcre-devel openssl-devel gcc curl make perl redis -y

WORKDIR /

COPY deps/ori/* /opt/winterfell_build/
COPY cmd/start.sh /opt/winterfell_cmd/
COPY src /opt/winterfell

WORKDIR /opt/winterfell_build/ 
RUN set -xe \
    && mkdir /logs \
    && tar -zxvf openresty-1.19.3.2.tar.gz \
    && tar -zxvf ngx_cache_purge-2.3.tar.gz -C openresty-1.19.3.2/bundle \
    && tar -xzvf nginx_upstream_check_module_v0.3.0.tar.gz -C /opt/winterfell_build/openresty-1.19.3.2/bundle \
    && cd openresty-1.19.3.2/bundle/LuaJIT-2.1-20201027 \
    && make && make install \
    && cd /opt/winterfell_build/openresty-1.19.3.2/  \
    && ./configure --prefix=/usr/winterfell --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-pcre --add-module=./bundle/ngx_cache_purge-2.3/ --add-module=./bundle/nginx_upstream_check_module-0.3.0/ -j2 \
    && make && make install \
    && cd /logs && rm -rf /opt/winterfell_build
 
CMD  sh -x /opt/winterfell_cmd/start.sh