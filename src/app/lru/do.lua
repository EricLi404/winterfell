local lru = require("dao/lru/common")
local json = require("cjson.safe")

local args = ngx.req.get_uri_args()

if args.set then
    lru.set(args.key, args.value, args.ttl)
    local resp = {}
    resp.code = 0
    resp.msg = "success"
    resp.data = {
        key = args.key,
        value = args.value,
        ttl = args.ttl
    }
    return ngx.print(json.encode(resp))
end

if args.get then
    local resp = {}
    resp.code = 0
    resp.msg = "success"
    resp.data = {
        key = args.key,
        value = lru.get(args.key) or "not exist",
    }
    return ngx.print(json.encode(resp))
end

