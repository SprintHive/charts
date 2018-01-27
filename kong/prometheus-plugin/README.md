# Kong Prometheus Plugin

Tracks internal kong metrics and exposes a prometheus endpoint on the Admin API to be scraped by a Prometheus Collector.

## Usage

```
$ curl -X POST http://localhost:8001/plugins -d "name=prometheus"
```

Now kong will track and monitor metrics across all apis and consumers.

You can view these metrics by going to:

```
http://localhost:8001/prometheus/metrics
```

## Metrics tracked

- `kong_http_requests_total` - Number of HTTP requests
- `kong_http_request_duration_seconds` - HTTP Request Latency
- `kong_http_request_size_bytes` - HTTP Request Size Bytes
- `kong_http_response_size_bytes` - HTTP Response Size Bytes
- `kong_upstream_http_request_wait_duration_seconds` - Upstream HTTP Request Time to First Byte Latency
- `kong_upstream_http_request_duration_seconds` - Upstream HTTP Request Latency
- `kong_connections_active` - Total number of active connections
- `kong_connections_reading` - Total number of connections reading
- `kong_connections_writing` - Total number of connections writing
- `kong_connections_waiting` - Total number of connections waiting

## Special Thanks

- To `knyar` for their `nginx-lua-prometheus` client which this was built around and uses to track metrics.

# Todo

- [x] Implement Prometheus endpoint
- [ ] Tests