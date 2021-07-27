local ffi = require 'ffi'
-- libzlog.so
local libzlog = ffi.load('zlog')
local format, sub, find = string.format, string.sub, string.find
local debug_getinfo = require 'debug'.getinfo

ffi.cdef [[
    typedef struct zlog_category_s zlog_category_t;
    zlog_category_t *zlog_get_category(const char *cname);
    int zlog_init(const char *confpath);
    int zlog_reload(const char *confpath);
    void zlog(zlog_category_t *category, const char *file, size_t filelen,
          const char *func, size_t funclen,
          long line, int level, const char *format, ...);
]]

local _M = {}

local ZLOG_CATEGORY_CACHE = {}
local LEVEL_DICT = {
    log = 20,
    debug = 20,
    info = 40,
    notice = 60,
    warn = 80,
    error = 100,
    fatal = 120,
}

function _M:init(zlog_conf_path)
    ngx.log(ngx.ERR, 'start init zlog')
    -- 对应nginx关闭后再打开
    local ok1 = libzlog.zlog_init(zlog_conf_path)
    if ok1 ~= 0 then
        -- 对应 -s reload
        local ok2 = libzlog.zlog_reload(zlog_conf_path)
        if ok2 ~= 0 then
            ngx.log(ngx.ERR, 'zlog init fail')
        end
    end
    ngx.log(ngx.ERR, 'end init zlog')
end

local function level_log(lvl, cat, fmt, ...)
    local lvl_code = LEVEL_DICT[lvl]
    if not lvl_code then
        return nil
    end
    -- 缓存zlog_cateory_t，提升一点性能
    local zlog_cateory
    if ZLOG_CATEGORY_CACHE[cat] then
        zlog_cateory = ZLOG_CATEGORY_CACHE[cat]
    else
        zlog_cateory = libzlog.zlog_get_category(cat)
        ZLOG_CATEGORY_CACHE[cat] = zlog_cateory
    end
    libzlog.zlog(zlog_cateory, '', 0, '', 0, 0, lvl_code, fmt, ...)
end

-- debug日志
-- 影响性能，线上不打开
function _M:c_debug(cat, fmt, ...)
    local info = debug_getinfo(3, 'Sn')
    local source = sub(info.short_src or '', find(info.short_src, "[%l%u%d_]+%.lua"))
    fmt = format('[%s] [%s] %s', source, (info.name or ''), fmt)
    level_log('debug', cat, fmt, ...)
end

return setmetatable(_M, {
    __index = function(_, lvl)
        if lvl == 'log' then
            return function(_, cat, fmt, ...)
                return level_log(lvl, cat, fmt, ...)
            end
        else
            return function(_, fmt, ...)
                return level_log(lvl, nil, fmt, ...)
            end
        end
    end
})
