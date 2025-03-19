terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
    }
  }
}

output "container_id" {
  value = proxmox_lxc.container.id
}

output "container_vmid" {
  value = split("/", proxmox_lxc.container.id)[2]
}

provider "proxmox" {
  pm_api_url      = "https://192.168.1.57:8006/api2/json"
  pm_tls_insecure = true
  pm_debug = true
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

  ssh_public_keys = file("~/.ssh/hub.local.pub")

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    firewall = false
    name   = "eth0"
    ip     = "dhcp"
    bridge = "vmbr0"
  }

   connection {
    type     = "ssh"
    user     = "root"
    host     = "hub.local"
    private_key = file("~/.ssh/hub.local")
  }

  provisioner "remote-exec" {
    when    = create
    inline  = [
      "id=${split("/", self.id)[2]}",
      "echo VM ID: $id",
      "lxc-info -s -n $id",
      "lxc-info -i -n $id",
      "ip=$(lxc-info -i -n $id)",
      "echo IP Address: $ip"
    ]
  }
}
