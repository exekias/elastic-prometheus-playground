terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

variable "instance_count" {
  default = "2"
}

variable "vm_name_prefix" {
  default = "carlos"
}

variable "elasticsearch" {
  type = map

  default = {
    hosts = "http://localhost:9200"
    username = "elastic"
    password = "changeme"
  }
}

provider "google" {
  version = "3.5.0"

  credentials = file("service-account.json")

  project = "<project_name>"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}

resource "google_compute_instance" "exporters" {
  count         = var.instance_count

  name         = "${var.vm_name_prefix}-prometheus-node-exporter-${count.index + 1}"
  machine_type = "e2-micro"
  labels       = {"prometheus_scrape": "true"}

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    //network = google_compute_network.vpc_network.name
    network = "default"
    access_config {
    }
  }

  metadata_startup_script = file("install_worker.sh")
}

resource "google_compute_instance" "prometheus" {
  name         = "${var.vm_name_prefix}-prometheus"
  machine_type = "e2-small"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  tags = ["http-server"]

  network_interface {
    //network = google_compute_network.vpc_network.name
    network = "default"
    access_config {
    }
  }

  service_account {
      scopes = ["compute-ro"]
  }

  metadata_startup_script = templatefile("install_collector.sh", {
      ELASTICSEARCH_HOSTS = var.elasticsearch.hosts,
      ELASTICSEARCH_USERNAME = var.elasticsearch.username,
      ELASTICSEARCH_PASSWORD = var.elasticsearch.password,
  })
}