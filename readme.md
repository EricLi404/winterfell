# Winterfell
各种 OpenResty（lua-nginx-module） 的最佳实践，提供了较为完整的运行环境、文档和测试脚本。

<!--ts-->
* [Winterfell](#winterfell)
   * [项目目录结构](#项目目录结构)
      * [基础目录结构](#基础目录结构)
      * [功能介绍（对应目录src/app/{{xxx}})](#功能介绍对应目录srcappxxx)
         * [base](#base)
         * [compute](#compute)
         * [lru](#lru)
         * [memcached](#memcached)
         * [redis](#redis)
   * [组件及引用说明](#组件及引用说明)
      * [openresty](#openresty)
      * [lua-protobuf](#lua-protobuf)
      * [xxx.pb](#xxxpb)
      * [redis 连接池实现](#redis-连接池实现)
      * [luajit](#luajit)
      * [mpx/lua-cjson](#mpxlua-cjson)
      * [redis or redis-cli](#redis-or-redis-cli)
      * [rd_tools](#rd_tools)
      * [markdown_gen_toc/gh-md-toc.sh](#markdown_gen_tocgh-md-tocsh)
         * [为 markdown 文件 生成 toc](#为-markdown-文件-生成-toc)
         * [使用 GitHub workflows 自动为 readme 添加 toc](#使用-github-workflows-自动为-readme-添加-toc)
   * [tar 包依赖](#tar-包依赖)
   * [wrk](#wrk)
      * [centos install wrk](#centos-install-wrk)
      * [wrk --help](#wrk---help)
      * [example wrk cmd](#example-wrk-cmd)
      * [wrk 测试报告解读](#wrk-测试报告解读)
   * [Docker 指令](#docker-指令)
      * [all in one](#all-in-one)
      * [build docker](#build-docker)
      * [run docker](#run-docker)
      * [enter docker](#enter-docker)
      * [restart docker](#restart-docker)

<!-- Added by: runner, at: Wed Jul 21 02:57:16 UTC 2021 -->

<!--te-->


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

### 功能介绍（对应目录`src/app/{{xxx}}`)

#### base
基础的 http get、post 演示，args、header 解析

#### compute
实现了一个计算器，主要为了演示 nginx.conf 的根据 uri 来选择使用的文件。
```
location ~ ^/compute/([-_a-zA-Z0-9/]+) {
   set $path $1;
   content_by_lua_file /opt/winterfell/app/compute/$path.lua;
}
```

#### lru
演示 resty.lrucache 的使用。

#### memcached
- `server`: 实现了基于 TCP 的 memcached 服务端(简版，只有 get、set)
- `client`：演示 resty.memcached 的使用

#### redis
演示了 redis 连接池的使用


## 组件及引用说明

### openresty

在 [openresty官网 #Lastest release](https://openresty.org/en/download.html#lastest-release) 下载

### lua-protobuf
目前在项目中已经被编译为 `/src/lualib/pb.so`

负责 对 pb msg 进行 encode、decode，使用说明见：[starwing/lua-protobuf](https://github.com/starwing/lua-protobuf)

### xxx.pb
proto 定义的二进制格式，使用 protoc 生成。

e.g. `protoc gdt_rta.proto  -o gdt.pb`

### redis 连接池实现
项目中的 `/src/lualib/redis_util.lua` 是一个redis连接池的封装。
基于 [moonbingbing/openresty-best-practices 中的「Redis 接口的二次封装」实现](https://github.com/moonbingbing/openresty-best-practices/blob/master/redis/out_package.md)

### luajit
由于 lua 对于大 table 处理的性能较差， 压测数据生成过程中可能会需要用到 luajit
```shell
git clone https://github.com/openresty/luajit2.git
cd luajit2
make && sudo make install
```

### mpx/lua-cjson
压测脚本可能需要依赖 cjson

Github: [https://github.com/mpx/lua-cjson/](https://github.com/mpx/lua-cjson/)
```shell
yum install wget pcre-devel openssl-devel gcc curl make perl -y
yum install lua-devel -y
wget https://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
tar -zxvf lua-cjson-2.1.0.tar.gz
cd lua-cjson-2.1.0
gmake
```
当前目录下的 `cjson.so` 即为所需 c lib 文件

###  redis or redis-cli

```shell
wget http://download.redis.io/releases/redis-5.0.3.tar.gz
tar -zxvf redis-5.0.3.tar.gz
cd redis-5.0.3
# 安装 redis-cli
make redis-cli  
# or 安装 redis 服务
make
```
此时 bin 文件就在 `./src` 中


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

#### 使用 GitHub workflows 自动为 readme 添加 toc
创建 `/.github/workflows/main.yml` 文件
内容为：
```shell
on:
  push:
    branches: [main]
    paths: ['readme.md']

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v2
      - run: |
          ./rd_tools/markdown_gen_toc/gh-md-toc.sh --insert --no-backup readme.md
      - uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: Auto update markdown TOC

```
同时在 `readme.md` 中添加 如下标记：
!!! `t s` 和 `t e` 中间应该是不带 空格 的，此处加空格是为了转义
```
<!--t s-->

<!--t e-->
```
push 代码到 GitHub 后，如果 `readme.md` 内容有改动，则会出发 workflow，自动为`readme.md`生成 toc。




## tar 包依赖
- [openresty-1.19.3.2](https://openresty.org/download/openresty-1.19.3.2.tar.gz)
- [ngx_cache_purge-2.3](https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz)
- [nginx_upstream_check_module-0.3.0](https://github.com/yaoweibin/nginx_upstream_check_module/archive/v0.3.0.tar.gz)


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