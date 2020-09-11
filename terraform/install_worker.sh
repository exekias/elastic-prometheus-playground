  #! /bin/bash
sudo curl -sSL https://get.docker.com/ | sh
sudo docker run -d --net=host --pid=host -v '/:/host:ro,rslave' quay.io/prometheus/node-exporter --path.rootfs=/host

sleep ${TEST_TIME_SECONDS}
sudo poweroff