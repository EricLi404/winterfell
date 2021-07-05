local _M = {}

local lrucache_prueffi = require "resty.lrucache.pureffi"

local ret, err = lrucache_prueffi.new(1000)

if not ret then
    ngx.log(ngx.ERR, "failed to create the cache: " .. (err or "unknown"))
    return nil
end

function _M.set(key, value, ttl)
    ret:set(key, value, ttl)
end

function _M.get(key)
    return ret:get(key)
end

function _M.delete(key)
    ret:delete(key)
end

return _M
