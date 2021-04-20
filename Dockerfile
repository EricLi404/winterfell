FROM centos:8
MAINTAINER EricLi404 <ericli404@hotmail.com>

RUN yum install wget pcre-devel openssl-devel gcc curl make perl -y

WORKDIR /
COPY nginx-lib/ori/* src/ /opt/winterfell_build/

WORKDIR /opt/winterfell_build/ 
RUN mkdir /logs && \
    tar -zxvf openresty-1.19.3.1.tar.gz && \
    tar -zxvf ngx_cache_purge-2.3.tar.gz -C openresty-1.19.3.1/bundle && \
    tar -xzvf nginx_upstream_check_module_v0.3.0.tar.gz -C /opt/winterfell_build/openresty-1.19.3.1/bundle 
   
RUN cd openresty-1.19.3.1/bundle/LuaJIT-2.1-20201027 && make clean && make && make install && \
    cd /opt/winterfell_build/openresty-1.19.3.1/ && \
     ./configure --prefix=/usr/winterfell  --with-luajit --with-http_realip_module --with-pcre \
     --add-module=./bundle/ngx_cache_purge-2.3/ --add-module=./bundle/nginx_upstream_check_module-0.3.0/ -j2 && \
    make && make install && \
    rm -rf /opt/winterfell_build
 
    
ENTRYPOINT ["sh","/opt/winterfell/cmd/start.sh"]