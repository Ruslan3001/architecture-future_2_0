variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "service_account_key_file" {
  description = "Path to Yandex Cloud service account authorized key JSON"
  type        = string
  default     = "../authorized_key.json"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "future-2-0-network"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vm_image_family" {
  description = "OS image family for VMs"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "vms" {
  description = "Map of VM configurations"
  type = map(object({
    cores     = number
    memory    = number
    disk_size = number
    disk_type = string
    has_nat   = bool
  }))
}
