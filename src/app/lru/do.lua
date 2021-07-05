local lru = require("app/lru/lru")

local args = ngx.req.get_uri_args()

if args.set then
    lru.set(args.key, args.value, args.ttl)
    ngx.say("set ", args.key, " |  ", args.value, " |  ", args.ttl , "success")
end

if args.get then
    ngx.say("get ", args.key, "  | ", lru.get(args.key))
end

