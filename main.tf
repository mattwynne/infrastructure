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

# See https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc
resource "proxmox_lxc" "container" {
  target_node   = "hub"
  hostname      = "test1"
  ostemplate    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  password      = "this is a test"
  memory = 512
  cores  = 1
  onboot = true
  start = true
  unprivileged = true

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    ip     = "192.168.1.200/24"
    bridge = "vmbr0"
  }
  
  connection {
    type     = "ssh"
    user     = "root"
    password = "this is a test"
    host     = self.network[0].ip
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y avahi-daemon"
    ]
  }

}
