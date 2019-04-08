# Metricbeat Prometheus Playground

This repository contains a simple scenario to ease the task of testing and developing [Metricbeat Prometheus integration](https://www.elastic.co/guide/en/beats/metricbeat/master/metricbeat-module-prometheus.html).

It will launch:

- [cadvisor](https://github.com/google/cadvisor)
- [node_exporter](https://github.com/prometheus/node_exporter)
- [Prometheus server](https://github.com/prometheus/prometheus), consuming from both cadvisor and node_exporter
- [Elasticsearch](https://www.elastic.co/products/elasticsearch)
- [Kibana](https://www.elastic.co/products/kibana)
- [Metricbeat](https://www.elastic.co/products/beats/metricbeat) consuming from both cadvisor and node_exporter


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
