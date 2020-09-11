  #! /bin/bash
sudo curl -sSL https://get.docker.com/ | sh

# node_exporter
sudo docker run -d --net=host --pid=host -v '/:/host:ro,rslave' quay.io/prometheus/node-exporter --path.rootfs=/host

# Elastic agent system package
cat << EOF > elastic-agent.yml
outputs:
  default:
    type: elasticsearch
    hosts: '${ELASTICSEARCH_HOSTS}'
    username: '${ELASTICSEARCH_USERNAME}'
    password: '${ELASTICSEARCH_PASSWORD}'

inputs:
  - name: system
    type: system/metrics
    use_output: default
    data_stream:
      namespace: default
    streams:
      - id: system/metrics-system.cpu
        data_stream:
          dataset: system.cpu
          type: metrics
        metricsets:
          - cpu
        cpu.metrics:
          - percentages
          - normalized_percentages
        period: 10s
      - id: system/metrics-system.diskio
        data_stream:
          dataset: system.diskio
          type: metrics
        metricsets:
          - diskio
        diskio.include_devices: null
        period: 10s
      - id: system/metrics-system.load
        data_stream:
          dataset: system.load
          type: metrics
        metricsets:
          - load
        period: 10s
      - id: system/metrics-system.memory
        data_stream:
          dataset: system.memory
          type: metrics
        metricsets:
          - memory
        period: 10s
      - id: system/metrics-system.network
        data_stream:
          dataset: system.network
          type: metrics
        metricsets:
          - network
        period: 10s
        network.interfaces: null
      - id: system/metrics-system.process
        data_stream:
          dataset: system.process
          type: metrics
        metricsets:
          - process
        period: 10s
        process.include_top_n.by_cpu: 5
        process.include_top_n.by_memory: 5
        process.cmdline.cache.enabled: true
        process.cgroups.enabled: true
        processes:
          - .*
      - id: system/metrics-system.process_summary
        data_stream:
          dataset: system.process_summary
          type: metrics
        metricsets:
          - process_summary
        period: 10s
      - id: system/metrics-system.socket_summary
        data_stream:
          dataset: system.socket_summary
          type: metrics
        metricsets:
          - socket_summary
        period: 10s
      - id: system/metrics-system.uptime
        data_stream:
          dataset: system.uptime
          type: metrics
        metricsets:
          - uptime
        period: 10s
EOF

sudo docker run --name elastic-agent -d --network host -v $(pwd)/elastic-agent.yml:/usr/share/elastic-agent/elastic-agent.yml docker.elastic.co/beats/elastic-agent:7.x-SNAPSHOT -e -v

sleep ${TEST_TIME_SECONDS}
sudo poweroff