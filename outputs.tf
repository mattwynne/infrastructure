output "containers" {
  value = local.containers
}

output "ids" {
  value = { for name, container in proxmox_virtual_environment_container.container : name => container.id }
  sensitive = true
}

output "container_private_key" {
  value     = tls_private_key.container_key.private_key_pem
  sensitive = true
}

output "container_public_key" {
  value = tls_private_key.container_key.public_key_openssh
}
