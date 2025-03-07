# Grafana

## Usage

Run the docker-compose file:

```bash
docker compose up -d
```

Open Grafana in your browser: http://localhost:3000

- Default credentials: admin / admin (prompted to change at first login).
- Click Connections → Data Sources → Add data source → Prometheus:
	- URL: http://prometheus:9090
	- Click Save & Test
	
- Click Explore
	- Browse metrics (after emitting some)

```ruby
# In another terminal

# Emit some metrics
require "metrics/backend/statsd"
client = Metrics::Backend::StatsD::Client.new

while true
	client.send_metric("test.counter", 1, type: "c")
	sleep(rand * 0.01)
end
```


You now have an elegant, simple, working StatsD setup!
