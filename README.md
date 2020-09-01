# Elastic Prometheus Playground

This repository contains a simple scenario to ease the task of testing and developing [Elastic Prometheus integration](https://www.elastic.co/guide/en/beats/metricbeat/master/metricbeat-module-prometheus.html).

It will launch:

- [node_exporter](https://github.com/prometheus/node_exporter)
- [Prometheus server](https://github.com/prometheus/prometheus), consuming from both cadvisor and node_exporter, sending a copy of them to Elastic through the `remote_write` endpoint in the Agent.
- [Elasticsearch](https://www.elastic.co/products/elasticsearch)
- [Kibana](https://www.elastic.co/products/kibana)
- [Elastic Agent](https://www.elastic.co/guide/en/ingest-management/current/run-elastic-agent.html) receiving metrics through the `remote_write` endpoint.


# Requirements

 - Install [docker-compose](https://docs.docker.com/compose/install/)

# Launch the scenario

```bash
git clone https://github.com/exekias/metricbeat-prometheus-playground.git
cd metricbeat-prometheus-playground
docker-compose up
```

# Profit

After bootstrap, you can access:

- Kibana: [http://localhost:5601](http://localhost:5601)
- Elasticsearch: [http://localhost:9200](http://localhost:9200)
