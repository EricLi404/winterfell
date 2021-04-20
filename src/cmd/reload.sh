#!/bin/bash
\cp /opt/winterfell/conf/nginx.conf /usr/winterfell/nginx/conf/nginx.conf
/usr/winterfell/nginx/sbin/nginx -t
/usr/winterfell/nginx/sbin/nginx -s reload