output "lxc_id" {
  description = "The ID of the created LXC container"
  value       = proxmox_vm_qemu.container.id
}
