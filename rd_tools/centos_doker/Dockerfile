FROM centos:7.9.2009
MAINTAINER EricLi404 <ericli404@hotmail.com>

RUN set -xe \
    && yum install epel-release -y \
    && yum update -y \
    && yum install wget pcre-devel openssl-devel gcc curl make perl -y \
    && yum install stress sysstat sysbench perf atop htop -y


ENTRYPOINT ["tail", "-f","/dev/null"]