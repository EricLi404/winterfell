---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by eric.
--- DateTime: 2021/7/5 7:34 下午
---

metric_status:observe(tonumber(ngx.var.request_time), { ngx.var.uri, ngx.var.status })

if ngx.ctx.error_code and type(ngx.ctx.error_code) == "number" and ngx.ctx.error_code > 0 then
    metric_error_code:inc(1, { ngx.var.uri, ngx.ctx.error_code })
end