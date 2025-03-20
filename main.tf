terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

locals {
  proxmox_host = "hub"
}

provider "proxmox" {
  pm_api_url      = "https://192.168.1.57:8006/api2/json"
  pm_tls_insecure = true
  pm_debug = true
}

# See https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc
resource "proxmox_lxc" "container" {
  target_node   = local.proxmox_host
  hostname      = "test1"
  ostemplate    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  memory = 512
  cores  = 1
  onboot = true
  start = true
  unprivileged = true

  ssh_public_keys = file("~/.ssh/hub.local.pub")

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    ip     = "dhcp"
    bridge = "vmbr0"
  }

  connection {
    type     = "ssh"
    user     = "root"
    host     = "${local.proxmox_host}.local"
    private_key = file("~/.ssh/hub.local")
  }

  provisioner "file" {
    source = "test1-init.sh"
    destination = "/root/test1-init.sh"
  }

  provisioner "remote-exec" {
    when    = create
    inline  = [
      "id=${split("/", proxmox_lxc.container.id)[2]}",
      "pct push $id /root/test1-init.sh /root/init.sh",
      "lxc-attach -n $id -- bash init.sh"
    ]
  }
}
