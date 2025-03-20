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
  endpoint = "https://192.168.1.57:8006/api2/json"
  insecure = true
}

# See https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc
resource "proxmox_virtual_environment_container" "container" {
  node_name   = local.proxmox_host
  vmid        = 100
  template    = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
  memory      = 512
  cpu {
    cores = 1
  }
  onboot      = true
  unprivileged = true

  ssh_keys = file("~/.ssh/hub.local.pub")

  disk {
    storage = "local-lvm"
    size    = 8
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = "${local.proxmox_host}.local"
    private_key = file("~/.ssh/hub.local")
  }

  provisioner "remote-exec" {
    inline = [
      "lxc-attach -n ${self.id} -- bash -c 'echo \"$(cat test1-init.sh)\" > /root/init.sh'",
      "lxc-attach -n ${self.id} -- bash /root/init.sh"
    ]
  }
}
