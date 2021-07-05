#!/bin/bash

redis-server &

sleep 3

/usr/winterfell/nginx/sbin/nginx -c /opt/winterfell/conf/nginx.conf -g 'daemon off;'

tail -f /dev/null