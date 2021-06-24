local lru = require("app/lru/lru")

local args = ngx.req.get_uri_args()

if args.set then
    for i = 1, 10000 do
        lru.set(args.key, args.value .. i, args.ttl)
    end
    ngx.say("set ", args.key, " |  ", args.value, " |  ", args.ttl)
end

if args.get then
    ngx.say("count: ", lru.count(), " capacity: ", lru.capacity())

    --if lru.get(args.key) then
    --    ngx.say("get ", args.key, "  | ", "1")
    --else
    --    ngx.say("get ", args.key, "  | ", "2")
    --end

end

