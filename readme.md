# Winterfell
各种 OpenResty（lua-nginx-module） 的最佳实践，提供了较为完整的运行环境、文档和测试脚本。

## 项目目录结构

### 基础目录结构
```
├── readme.md          —— 本文件
├── src                —— 服务资源跟路径
│   ├── app            —— 业务控制层代码
│   │   └── {{xxx}}    —— 每个目录代表一项不同的业务功能
│   ├── conf           —— 配置文件
│   ├── dao            —— 数据处理层
│   │   └── lru        —— lrucache instence
│   └── lualib         —— lua、c 库文件
├── cmd                —— 服务运行指令
│   └── start.sh       —— 服务启动脚本
├── deps               —— 基础第三方依赖
│   └── ori            —— 第三方依赖 tar 文件
├── rd_tools           —— 开发、debug过程中可以使用的便利性工具
├── build.sh           —— 编译运行 docker container
├── Dockerfile         —— Dockerfile
├── LICENSE            —— LICENSE

```

### 业务目录结构
```
├── base              
│   ├── debug.lua
│   ├── decode.lua
│   └── random.lua
├── common
│   ├── init_worker.lua
│   ├── logger.lua
│   ├── param.lua
│   └── response.lua
├── compute
│   ├── divide.lua
│   ├── lib
│   │   └── access_check.lua
│   ├── minus.lua
│   ├── multiply.lua
│   └── plus.lua
├── lru
│   └── do.lua
├── memcached
│   └── memc.lua
└── redis
    ├── get.lua
    └── set.lua
```

### rd_tools

### markdown_gen_toc/gh-md-toc.sh

#### 为 markdown 文件 生成 toc
usage：
```
➜ ./rd_tools/markdown_gen_toc/gh-md-toc.sh readme.md

Table of Contents
=================

* [Winterfell](#winterfell)
* [Table of Contents](#table-of-contents)
   * [项目目录结构](#项目目录结构)
      * [基础目录结构](#基础目录结构)
      * [业务目录结构](#业务目录结构)
      * [rd_tools](#rd_tools)
      * [markdown_gen_toc/gh-md-toc.sh](#markdown_gen_tocgh-md-tocsh)
   * [包依赖](#包依赖)
   * [Docker 指令](#docker-指令)
      * [all in one](#all-in-one)
      * [build docker](#build-docker)
      * [run docker](#run-docker)
      * [enter docker](#enter-docker)
      * [restart docker](#restart-docker)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)
```


thanks to [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)




## wrk

### centos install wrk

```shell
yum groupinstall 'Development Tools' -y 
yum install -y openssl-devel git -y 
git clone https://github.com/wg/wrk.git wrk
cd wrk
make
cp wrk /usr/local/bin/
```

### wrk --help
```
使用方法: wrk <选项> <被测HTTP服务的URL>                            
  Options:                                            
    -c, --connections <N>  跟服务器建立并保持的TCP连接数量  
    -d, --duration    <T>  压测时间           
    -t, --threads     <N>  使用多少个线程进行压测   
                                                      
    -s, --script      <S>  指定Lua脚本路径       
    -H, --header      <H>  为每一个HTTP请求添加HTTP头      
        --latency          在压测结束后，打印延迟统计信息   
        --timeout     <T>  超时时间     
    -v, --version          打印正在使用的wrk的详细版本信息
                                                      
  <N>代表数字参数，支持国际单位 (1k, 1M, 1G)
  <T>代表时间参数，支持时间单位 (2s, 2m, 2h)
```

### example wrk cmd
```shell
wrk -t2 -d1s -c10 -s test.lua --latency http://127.0.0.1:8189
```

### wrk 测试报告解读

统计分为 **Thread Stats** 和 **Latency Distribution** 两个级别：
- **Thread Stats** Thread级别统计信息
- **Latency Distribution** 整体统计信息

涉及到两个 qps ：
- `Thread Stats` . `Avg` . `Req/Sec` : 在测试中每个线程一定时间间隔内做统计，平均 qps
- `Requests/sec` : 压测结束后，统计  `总请求/总时间`

`Thread Stats` . `Avg` . `Req/Sec`  *  `thread 数量`  =  `Requests/sec`


```text
wrk -t32 -c256 -d1m -s wrk_request.lua --latency  http://127.0.0.1
Running 1m test @ http://127.0.0.1 （运行1分钟测试）
  32 threads and 256 connections（32个线程256个连接）
  Thread Stats (Thread级别统计信息)   Avg (均值)     Stdev (标准差值)    Max (最大值)  +/- Stdev (正负标准差值)
    Latency (Thread级别延迟)          9.78ms         10.92ms           306.71ms      95.92%
    Req/Sec (Thread级别的qps)         0.92k          222.74            3.03k         86.26%
  Latency Distribution (整体统计信息)
     50%    7.95ms
     75%   10.36ms
     90%   14.02ms
     99%   39.95ms
  1794482 requests in 1.00m, 516.74MB read   (1分钟内处理了1794482个请求，耗费流量516.74MB)
  Non-2xx or 3xx responses: 32   （错误信息）
Requests/sec:  29860.74          （qps）
Transfer/sec:      8.60MB

```



## 包依赖
- [openresty-1.19.3.1](https://openresty.org/download/openresty-1.19.3.1.tar.gz)
- [ngx_cache_purge-2.3](https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz)
- [nginx_upstream_check_module-0.3.0](https://github.com/yaoweibin/nginx_upstream_check_module/archive/v0.3.0.tar.gz)

## Docker 指令

### all in one
根路径下的 `rebuild.sh` 会执行重新构建 docker container 的一系列指令
```shell
sh build.sh
```

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