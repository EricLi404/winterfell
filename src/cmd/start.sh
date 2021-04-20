#!/bin/bash
\cp /opt/winterfell/conf/nginx.conf /usr/winterfell/nginx/conf/nginx.conf
/usr/winterfell/nginx/sbin/nginx
tail -f /dev/null