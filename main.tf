terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.api_url
  pm_user         = var.user
  pm_password     = var.password
  pm_tls_insecure = true
}


resource "proxmox_lxc" "container" {
  hostname      = "terraform-lxc"
  ostemplate    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  target_node   = var.target_node

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  memory = 512
  cores  = 1
  network {
    name = "eth0"
    ip   = "dhcp"
  }
}
