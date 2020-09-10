  #! /bin/bash
sudo curl -sSL https://get.docker.com/ | sh

# Prometheus
cat << EOF > prometheus.yml
scrape_configs:
- job_name: node_exporter
  scrape_interval: 10s
  gce_sd_configs:
  - project: elastic-observability
    zone: europe-west1-b
    port: 9100
    filter: (labels.prometheus_scrape = true)

remote_write:
  - url: "http://localhost:9201/write"
EOF

sudo docker run -d --net=host -p 80:9090 -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

# Agent
cat << EOF > elastic-agent.yml
outputs:
  default:
    type: elasticsearch
    hosts: '${ELASTICSEARCH_HOSTS}'
    username: '${ELASTICSEARCH_USERNAME}'
    password: '${ELASTICSEARCH_PASSWORD}'

inputs:
  - type: prometheus/metrics

    data_stream.namespace: default
    use_output: default
    streams:
      - metricset: remote_write
        data_stream.dataset: prometheus.remote_write
        host: "0.0.0.0"
        port: "9201"
        use_types: true
EOF

sudo docker run -d --net=host -v $(pwd)/elastic-agent.yml:/usr/share/elastic-agent/elastic-agent.yml docker.elastic.co/beats/elastic-agent:7.x-SNAPSHOT