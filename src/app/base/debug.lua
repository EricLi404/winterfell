---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by eric.
--- DateTime: 2021/4/17 11:37 上午
---
local json = require "cjson"

local args = ngx.req.get_uri_args()
local headers = ngx.req.get_headers()
local method = ngx.req.get_method()

-- post body_data 需要先read
ngx.req.read_body()
-- 针对 application/x-www-form-urlencoded ，可以解析为 table ，其他形式可能解析不太友好
local post_args = ngx.req.get_post_args()
-- It returns a Lua string rather than a Lua table holding all the parsed query arguments
local data = ngx.req.get_body_data()
if not data then
    -- body may get buffered in a temp file:
    local file = ngx.req.get_body_file()
    if file then
        data = file
    end
end

-- TODO 可以指定返回若干参数
local rtn = {}
rtn.uri_args = args
rtn.post_args = post_args
rtn.method = method
rtn.headers = headers
rtn.body = body_data
rtn.host = ngx.var.host
rtn.hostname = ngx.var.hostname
rtn.uri = ngx.var.uri

ngx.say(json.encode(rtn))



