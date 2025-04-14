output "containers" {
  value = local.containers
}

output "ids" {
  value     = proxmox_virtual_environment_container.container[each.key]
  sensitive = true
}

output "container_private_key" {
  value     = tls_private_key.container_key.private_key_pem
  sensitive = true
}

output "container_public_key" {
  value = tls_private_key.container_key.public_key_openssh
}
