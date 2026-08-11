output "network_id" {
  description = "ID of the created VPC network"
  value       = yandex_vpc_network.main.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = yandex_vpc_subnet.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway"
  value       = yandex_vpc_gateway.nat.id
}

output "security_group_id" {
  description = "ID of the main security group"
  value       = yandex_vpc_security_group.main.id
}

output "vm_internal_ips" {
  description = "Map of VM names to internal IP addresses"
  value       = { for k, vm in yandex_compute_instance.vm : k => vm.network_interface[0].ip_address }
}

output "vm_nat_ips" {
  description = "Map of VM names to public IP addresses (for VMs with NAT enabled)"
  value       = { for k, vm in yandex_compute_instance.vm : k => vm.network_interface[0].nat_ip_address }
}

output "disk_ids" {
  description = "Map of VM names to boot disk IDs"
  value       = { for k, disk in yandex_compute_disk.vm_disk : k => disk.id }
}
