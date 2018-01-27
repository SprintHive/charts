-- Core Modules
local singletons           = require "kong.singletons"
local base_plugin          = require "kong.plugins.base_plugin"
local shared_dict          = require "kong.plugins.prometheus.dict"
local prometheus           = require "kong.plugins.prometheus.client"

-- External Stats Collectors
local basic_metrics        = require "kong.plugins.log-serializers.basic"

-- Plugin objects
local prometheus_plugin    = base_plugin:extend()

-- Plugin singletons
singletons.prometheus_collectors  = {}

-- Plugin constructor
function prometheus_plugin:new()
  prometheus_plugin.super.new(self, "prometheus")
  
  -- Initialize Prometheus Collector Object
  local global_dict = shared_dict("kong_prometheus_global_dict")
  local global_collector = prometheus.init("kong_prometheus_global_dict")
  local global_metrics = {}

  singletons.prometheus_collectors.global = {
    dict = global_dict,
    collector = global_collector,
    metrics = global_metrics
  }

  -- Stat Objects
  local generic_stats = {"protocol", "host", "port", "path", "status", "remote_addr", "api_id", "consumer_id"}
  local entity_stats = {"api_id", "consumer_id"}

  -- Initialize Metric Buckets
  global_metrics.request_count = global_collector:counter(
    "kong_http_requests_total", "Number of HTTP requests", generic_stats)

  global_metrics.request_latency = global_collector:histogram(
    "kong_http_request_duration_seconds", "HTTP Request Latency", generic_stats)

  global_metrics.request_size = global_collector:counter(
    "kong_http_request_size_bytes", "HTTP Request Size Bytes", generic_stats)

  global_metrics.response_size = global_collector:counter(
    "kong_http_response_size_bytes", "HTTP Response Size Bytes", generic_stats)

  global_metrics.proxy_first_byte_latency = global_collector:histogram(
    "kong_upstream_http_request_wait_duration_seconds", "Upstream HTTP Request Time to First Byte Latency", generic_stats)

  global_metrics.proxy_latency = global_collector:histogram(
    "kong_upstream_http_request_duration_seconds", "Upstream HTTP Request Latency", generic_stats)

  global_metrics.connections_active = global_collector:counter(
    "kong_connections_active", "Total number of active connections")

  global_metrics.connections_reading = global_collector:counter(
    "kong_connections_reading", "Total number of connections reading")

  global_metrics.connections_writing = global_collector:counter(
    "kong_connections_writing", "Total number of connections writing")

  global_metrics.connections_waiting = global_collector:counter(
    "kong_connections_waiting", "Total number of connections waiting")
end

---[[ runs in the 'log_by_lua_block'
function prometheus_plugin:log(plugin_conf)
  prometheus_plugin.super.access(self)

  -- Get Prometheus collector metrics object
  local metrics = singletons.prometheus_collectors.global.metrics
  local collector = singletons.prometheus_collectors.global.collector

  -- Get Basic Stats
  local stats = basic_metrics.serialize(ngx)

  -- Get Authenticated / API values
  local api_id = (stats.api and stats.api.id or 'global')
  local consumer_id = (stats.authenticated_entity and stats.authenticated_entity.consumer_id or 'anonymous')

  -- Extend request stats
  stats.request.protocol = ngx.var.scheme
  stats.request.host = ngx.var.host:gsub("^www.", "")
  stats.request.port = ngx.var.server_port

  -- General details object
  local request_details = {
    stats.request.protocol,
    stats.request.host,
    stats.request.port,
    stats.request.uri,
    stats.response.status,
    stats.client_ip,
    api_id,
    consumer_id
  }

  -- Entity detail object
  local entity_details = {
    api_id,
    consumer_id
  }

  -- Basic Connection metrics
  metrics.connections_active:inc(tonumber(ngx.var.connections_active))
  metrics.connections_reading:inc(tonumber(ngx.var.connections_reading))
  metrics.connections_waiting:inc(tonumber(ngx.var.connections_waiting))
  metrics.connections_writing:inc(tonumber(ngx.var.connections_writing))

  -- Request Latency
  metrics.request_latency:observe(ngx.now() - ngx.req.start_time(), request_details)

  -- Request Count
  metrics.request_count:inc(1, request_details)

  -- Sizes
  metrics.request_size:inc(tonumber(ngx.var.request_length), request_details)
  metrics.response_size:inc(tonumber(ngx.var.bytes_sent), request_details)

  -- Proxy Latency
  if ngx.ctx.KONG_PROXIED then
    -- Add the time waiting for upstream response and response handle time
    -- to determine the total upstream time taken
    local kong_wait_time = ngx.ctx.KONG_WAITING_TIME or 0
    local kong_receive_time = ngx.ctx.KONG_RECEIVE_TIME or 0
    local kong_upstream_time = kong_wait_time + kong_receive_time

    metrics.proxy_first_byte_latency:observe(kong_wait_time / 1000, request_details)
    metrics.proxy_latency:observe(kong_upstream_time / 1000, request_details)
  end

  -- collector:debug()
end --]]

-- set the plugin priority, which determines plugin execution order
prometheus_plugin.PRIORITY = 1000

-- return our plugin object
return prometheus_plugin
