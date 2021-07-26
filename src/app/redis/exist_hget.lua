---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by eric.
--- DateTime: 2021/7/21 5:44 下午
---

local app_config = require("conf.app_config")
local config = app_config.redis_hget()
local cjson = require("cjson.safe")
local redis = require("lualib.redis_util")

ngx.req.read_body()
local request_byte = ngx.req.get_body_data()

local request = cjson.decode(request_byte)

local req_id = request.id

ngx.ctx.requestlog = request

local function response_msg(msg)
    local response_table = { msg = msg }
    local encodeStr = cjson.encode(response_table)
    ngx.ctx.responselog = response_table
    return encodeStr
end

local red, new_err = redis:new(config.redis_opts);
-- red:new 出问题，快速返回
if new_err then
    ngx.log(ngx.ERR, "failed to new redis:", (new_err or "unknown"))
    return ngx.print(response_msg("error"))
end

local res, err = red:exists(req_id)

-- red:exists 出问题，快速返回
if err or type(res) ~= "number" then
    ngx.log(ngx.ERR, "failed to exists:", (err or "unknown"))
    return ngx.print(response_msg("error"))
end

if res ~= 1 then
    ngx.ctx.redis_key_exists = "notexists"
    return ngx.print(response_msg("no"))
end

ngx.ctx.redis_key_exists = "exists"

local wmValue, h_err = red:hget(req_id, 'gdt')

-- red:hget 出问题，快速返回
if h_err then
    ngx.log(ngx.ERR, "failed to hget:", h_err)
    return ngx.print(response_msg("error"))
end

-- hsah value 存的是当天日期，快速返回
if type(wmValue) == "string" and wmValue == ngx.today() then
    return ngx.print(response_msg("no"))
end

return ngx.print(response_msg("yes"))