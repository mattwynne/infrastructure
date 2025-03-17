terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "vm" {
  name        = "terraform-vm"
  target_node = "your-target-node"
  clone       = "100"

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
  ostemplate    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
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
