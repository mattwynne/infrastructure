output "lxc_id" {
  description = "The ID of the created LXC container"
  value       = proxmox_lxc.container.id
}
