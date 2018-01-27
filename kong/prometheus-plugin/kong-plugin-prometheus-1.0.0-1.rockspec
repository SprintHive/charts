package = "kong-plugin-prometheus"
version = "1.0.0-1"

supported_platforms = {"linux", "macosx"}
source = {
  url = "git://github.com/nijikokun/kong-plugin-prometheus",
  tag = "1.0.0"
}

description = {
  summary = "Kong Prometheus plugin exposes a Prometheus Metrics endpoint to be used by the Prometheus Gateway",
  homepage = "http://getkong.org",
  license = "MIT"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.prometheus.handler"] = "kong/plugins/prometheus/handler.lua",
    ["kong.plugins.prometheus.schema"] = "kong/plugins/prometheus/schema.lua",
    ["kong.plugins.prometheus.client"] = "kong/plugins/prometheus/client.lua",
    ["kong.plugins.prometheus.dict"] = "kong/plugins/prometheus/dict.lua",
    ["kong.plugins.prometheus.api"] = "kong/plugins/prometheus/api.lua",
  }
}
