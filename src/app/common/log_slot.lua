local cjson = require "cjson"
local logger = require "lualib.zlog_logger"

local jsonlog = {}
jsonlog["status"] = ngx.var.status;
jsonlog["request_time"] = ngx.var.request_time;
jsonlog["request"] = cjson.encode(ngx.ctx.requestlog);
jsonlog["response"] = cjson.encode(ngx.ctx.responselog);
logger:log("zlog", "%s", cjson.encode(jsonlog))

