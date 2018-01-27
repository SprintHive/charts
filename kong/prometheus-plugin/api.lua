local singletons           = require "kong.singletons"

function send_raw(status_code, content)
  ngx.status = status_code
  ngx.say(content)
  ngx.exit(ngx.status)
end

return {
  ["/prometheus/metrics"] = {
    GET = function(self, dao_factory, helpers)
      singletons.prometheus_collectors.global.collector:collect()
      ngx.exit(200)
    end
  }
}