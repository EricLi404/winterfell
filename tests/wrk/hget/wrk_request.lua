local cjson = require("cjson")

s_headers = { ["Content-Type"] = "application/json" }
local requests = {}
local request_idx = 1

for i = 1, 20 do
    local request_table = {
        id = "hget:key:" .. tostring(i)
    }
    table.insert(requests, cjson.encode(request_table))
end

local length = #requests

for _ = 1, length do
    local m, n = math.random(length), math.random(length)
    requests[m], requests[n] = requests[n], requests[m]
end

function request()
    local pbm = requests[request_idx % length]
    request_idx = request_idx + 1
    return wrk.format("POST", "/redis/exist_hget", s_headers, pbm)
end