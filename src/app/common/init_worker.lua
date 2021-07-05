require("dao/lru/common")

prometheus = require("lualib.prometheus.prometheus").init("prometheus_metrics")
metric_status = prometheus:histogram("metric_status", "HTTP request latency", { "api", "status" },
        { 0.003, 0.005, 0.01, 0.015, 0.02, 0.025, 0.03, 0.035, 0.04, 0.045, 0.05, 0.055, 0.06, 0.065, 0.07, 0.08, 0.1, 0.5, 1 })
metric_error_code = prometheus:counter("metric_error_code", "Number of api error", { "api", "error_code" })