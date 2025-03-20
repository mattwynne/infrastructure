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
  username = "terraform-prov@pve" 
}

resource "proxmox_virtual_environment_container" "container" {
  node_name   = local.proxmox_host
  vm_id        = 100

  initialization {
    hostname = "test1"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        file("~/.ssh/hub.local.pub")
      ]
    }
  }

  network_interface {
    name = "veth0"
  }

  operating_system {
    # template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    template_file_id = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    type             = "ubuntu"
  }

  # memory      = 512
  # cpu {
  #   cores = 1
  # }
  # onboot      = true
  # unprivileged = true

  # ssh_keys = file("~/.ssh/hub.local.pub")

  # disk {
  #   storage = "local-lvm"
  #   size    = 8
  # }

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
