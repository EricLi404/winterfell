# Winterfell


## 包依赖
- [openresty-1.19.3.1](https://openresty.org/download/openresty-1.19.3.1.tar.gz)
- [ngx_cache_purge-2.3](https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz)
- [nginx_upstream_check_module-0.3.0](https://github.com/yaoweibin/nginx_upstream_check_module/archive/v0.3.0.tar.gz)

## 指令

### build docker
```shell
docker build -t winterfell:1.0 .
```

### run docker 
```shell
docker run --name wf -d -v $PWD/src:/opt/winterfell -v /tmp/wf_logs:/logs -p 8189:80 winterfell:1.0
```

### enter docker 
```shell
docker exec -it wf /bin/sh
```

### restart docker
```shell
docker restart wf 
```