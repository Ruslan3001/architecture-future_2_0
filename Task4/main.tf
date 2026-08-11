terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.124"
    }
  }
  required_version = ">= 1.9.0"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family
}

resource "yandex_vpc_network" "main" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "main" {
  name           = "${var.network_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
  route_table_id = yandex_vpc_route_table.nat.id
}

resource "yandex_vpc_gateway" "nat" {
  name = "${var.network_name}-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "nat" {
  name       = "${var.network_name}-nat-route"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_security_group" "main" {
  name        = "${var.network_name}-sg"
  description = "Basic security group for Future 2.0 infrastructure"
  network_id  = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow internal traffic"
    v4_cidr_blocks = [var.subnet_cidr]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_compute_disk" "vm_disk" {
  for_each = var.vms

  name     = "${each.key}-disk"
  type     = each.value.disk_type
  zone     = var.zone
  size     = each.value.disk_size
  image_id = data.yandex_compute_image.ubuntu.image_id
}

resource "yandex_compute_instance" "vm" {
  for_each = var.vms

  name        = each.key
  zone        = var.zone
  platform_id = "standard-v3"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.vm_disk[each.key].id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main.id
    nat                = each.value.has_nat
    security_group_ids = [yandex_vpc_security_group.main.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
