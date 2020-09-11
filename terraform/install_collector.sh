  #! /bin/bash
sudo curl -sSL https://get.docker.com/ | sh


docker network create collector

# Agent
cat << EOF > elastic-agent.yml
outputs:
  default:
    type: elasticsearch
    hosts: '${ELASTICSEARCH_HOSTS}'
    username: '${ELASTICSEARCH_USERNAME}'
    password: '${ELASTICSEARCH_PASSWORD}'

agent.monitoring:
  enabled: false
  logs: false
  metrics: false
agent.logging.level: info

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

sudo docker run \
  --name elastic-agent \
  -d \
  --network collector \
  -v $(pwd)/elastic-agent.yml:/usr/share/elastic-agent/elastic-agent.yml \
  docker.elastic.co/beats/elastic-agent:7.x-SNAPSHOT \
  -e -v

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
  - url: "http://elastic-agent:9201/write"
EOF

sudo mkdir /prometheus_data
sudo chown -R 65534:65534 /prometheus_data

sudo docker run \
  --name prometheus \
  -d  \
  --network collector \
  -p 80:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /prometheus_data:/prometheus \
  prom/prometheus

sleep ${TEST_TIME_SECONDS}
sudo docker stop prometheus
sudo docker stop elastic-agent
sudo poweroff