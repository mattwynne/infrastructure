output "containers" {
  value = local.containers
}

output "container_ips" {
  value = { for name, container in local.containers : name => container.hostname }
}

output "ids" {
  value = { for name, container in proxmox_virtual_environment_container.container : name => container.id }
}

output "container_private_key" {
  value     = tls_private_key.container_key.private_key_pem
  sensitive = true
}

output "container_public_key" {
  value = tls_private_key.container_key.public_key_openssh
}
