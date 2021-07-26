FROM centos:7.3.1611
MAINTAINER EricLi404 <ericli404@hotmail.com>

RUN set -xe \
    && yum install epel-release -y \
    && yum update -y \
    && yum install wget pcre-devel openssl-devel gcc curl make perl redis -y

WORKDIR /

COPY deps/ori/* /opt/winterfell_build/
COPY cmd/start.sh /opt/winterfell_cmd/
COPY src /opt/winterfell
COPY tests rd_tools /opt/winterfell_others/

WORKDIR /opt/winterfell_build/ 
RUN set -xe \
    && mkdir /logs \
    && tar -zxvf zlog-1.2.15.tar.gz \
    && cd zlog-1.2.15 && make && make install \
    && echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig \
    && cd /opt/winterfell_build/ \
    && tar -zxvf openresty-1.19.3.2.tar.gz \
    && cd openresty-1.19.3.2/bundle/LuaJIT-2.1-20201027 \
    && make && make install \
    && cd /opt/winterfell_build/openresty-1.19.3.2/  \
    && ./configure --prefix=/usr/winterfell --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-pcre -j2 \
    && make && make install \
    && cd /logs && rm -rf /opt/winterfell_build
 
CMD  sh -x /opt/winterfell_cmd/start.sh