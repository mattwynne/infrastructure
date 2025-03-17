provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "vm" {
  name        = "terraform-vm"
  target_node = var.pm_target_node
  clone       = var.pm_clone_template

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    size    = "10G"
    type    = "scsi"
    storage = "local-lvm"
  }

  os_type = "cloud-init"
}

resource "proxmox_lxc" "container" {
  hostname      = "terraform-lxc"
  ostemplate    = var.lxc_template
  storage       = "local-lvm"
  rootfs        = "8G"
  memory        = 512
  cpus          = 1
  target_node   = var.pm_target_node
  network {
    name = "eth0"
    ip   = "dhcp"
  }
}
