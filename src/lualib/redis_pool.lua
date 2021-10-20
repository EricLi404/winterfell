local redis_c = require "resty.redis"


local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function(narr, nrec)
        return {}
    end
end

local _M = new_tab(0, 155)
_M._VERSION = '0.02'

local commands = {
    "append", "auth", "bgrewriteaof",
    "bgsave", "bitcount", "bitop",
    "blpop", "brpop",
    "brpoplpush", "client", "config",
    "dbsize",
    "debug", "decr", "decrby",
    "del", "discard", "dump",
    "echo",
    "eval", "exec", "exists",
    "expire", "expireat", "flushall",
    "flushdb", "get", "getbit",
    "getrange", "getset", "hdel",
    "hexists", "hget", "hgetall",
    "hincrby", "hincrbyfloat", "hkeys",
    "hlen",
    "hmget", "hmset", "hscan",
    "hset",
    "hsetnx", "hvals", "incr",
    "incrby", "incrbyfloat", "info",
    "keys",
    "lastsave", "lindex", "linsert",
    "llen", "lpop", "lpush",
    "lpushx", "lrange", "lrem",
    "lset", "ltrim", "mget",
    "migrate",
    "monitor", "move", "mset",
    "msetnx", "multi", "object",
    "persist", "pexpire", "pexpireat",
    "ping", "psetex", "psubscribe",
    "pttl",
    "publish", --[[ "punsubscribe", ]]   "pubsub",
    "quit",
    "randomkey", "rename", "renamenx",
    "restore",
    "rpop", "rpoplpush", "rpush",
    "rpushx", "sadd", "save",
    "scan", "scard", "script",
    "sdiff", "sdiffstore",
    "select", "set", "setbit",
    "setex", "setnx", "setrange",
    "shutdown", "sinter", "sinterstore",
    "sismember", "slaveof", "slowlog",
    "smembers", "smove", "sort",
    "spop", "srandmember", "srem",
    "sscan",
    "strlen", --[[ "subscribe",  ]]     "sunion",
    "sunionstore", "sync", "time",
    "ttl",
    "type", --[[ "unsubscribe", ]]    "unwatch",
    "watch", "zadd", "zcard",
    "zcount", "zincrby", "zinterstore",
    "zrange", "zrangebyscore", "zrank",
    "zrem", "zremrangebyrank", "zremrangebyscore",
    "zrevrange", "zrevrangebyscore", "zrevrank",
    "zscan",
    "zscore", "zunionstore", "evalsha"
}

local mt = { __index = _M }

local function is_redis_null(res)
    if type(res) == "table" then
        for k, v in pairs(res) do
            if v ~= ngx.null then
                return false
            end
        end
        return true
    elseif res == ngx.null then
        return true
    elseif res == nil then
        return true
    end

    return false
end


-- change connect address as you need
function _M.connect_mod(self, redis)
    redis:set_timeouts(self.opts.connect_timeout, self.opts.send_timeout, self.opts.read_timeout)

    -- set redis host,port
    return redis:connect(self.opts.host, self.opts.port)
end

local function do_command(self, cmd, ...)
    if self._reqs then
        table.insert(self._reqs, { cmd, ... })
        return
    end

    local redis, err = redis_c:new()
    if not redis then
        return nil, err
    end

    local ok, err = self:connect_mod(redis)
    if not ok or err then
        return nil, err
    end

    local fun = redis[cmd]
    local result, err = fun(redis, ...)
    if not result or err then
        -- ngx.log(ngx.ERR, "pipeline result:", result, " err:", err)
        return nil, err
    end

    if is_redis_null(result) then
        result = nil
    end

    redis:set_keepalive_mod(self.opts.keepalive, self.opts.pool_size)

    return result, err
end

local function _parse_opts(opts)
    local d_opts = {
        connect_timeout = 3000, --3s
        send_timeout = 200, --200ms
        read_timeout = 200, --200ms
        host = '127.0.0.1',
        port = 6379,
        db_index = 0,
        password = nil,
        keepalive = 60000, --60s
        pool_size = 100
    }

    for k, v in pairs(opts) do
        if k == "host" then
            if type(v) ~= "string" then
                return nil, '"host" must be a string'
            end
            d_opts.host = v
        elseif k == "port" then
            if type(v) ~= "number" then
                return nil, '"port" must be a number'
            end
            if v < 0 or v > 65535 then
                return nil, '"port" out of range 0~65535'
            end
            d_opts.port = v
        elseif k == "password" then
            if type(v) ~= "string" then
                return nil, '"password" must be a string'
            end
            d_opts.password = v
        elseif k == "db_index" then
            if type(v) ~= "number" then
                return nil, '"db_index" must be a number'
            end
            if v < 0 then
                return nil, '"db_index" must be >= 0'
            end
            d_opts.db_index = v
        elseif k == "connect_timeout" then
            if type(v) ~= "number" or v < 0 then
                return nil, 'invalid "connect_timeout"'
            end
            d_opts.connect_timeout = v
        elseif k == "send_timeout" then
            if type(v) ~= "number" or v < 0 then
                return nil, 'invalid "send_timeout"'
            end
            d_opts.send_timeout = v
        elseif k == "read_timeout" then
            if type(v) ~= "number" or v < 0 then
                return nil, 'invalid "read_timeout"'
            end
            d_opts.read_timeout = v
        elseif k == "keepalive" then
            if type(v) ~= "number" or v < 0 then
                return nil, 'invalid "keepalive"'
            end
            d_opts.keepalive = v
        elseif k == "pool_size" then
            if type(v) ~= "number" or v < 0 then
                return nil, 'invalid "pool_size"'
            end
            d_opts.pool_size = v
        elseif k == "commands" then
            if type(v) ~= "table" or #v < 1 then
                return nil, 'invalid "commands"'
            end
            commands = v
        end
    end
    return d_opts
end

function _M.new(self, opts)
    local n_opts = _parse_opts(opts)
    for i = 1, #commands do
        local cmd = commands[i]
        _M[cmd] = function(self, ...)
            return do_command(self, cmd, ...)
        end
    end
    ngx.socket.tcp()
    return setmetatable({ opts = n_opts, _reqs = nil }, mt)
end

return _M