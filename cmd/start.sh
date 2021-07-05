#!/bin/bash

/usr/winterfell/nginx/sbin/nginx -c /opt/winterfell/conf/nginx.conf -g 'daemon off;'

tail -f /dev/null