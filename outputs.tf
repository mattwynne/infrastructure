output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_vm_qemu.vm.id
}

output "lxc_id" {
  description = "The ID of the created LXC container"
  value       = proxmox_lxc.container.id
}
