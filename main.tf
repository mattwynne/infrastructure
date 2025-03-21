terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://hub.local:8006/"
  insecure = true
  tmp_dir  = "/var/tmp"

  ssh {
    # agent = true
    private_key = file("~/.ssh/hub.local")
    # TODO: uncomment and configure if using api_token instead of password
    # username = "root"
  }
}

resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Managed by Terraform"

  node_name = "hub"
  vm_id     = 101

  disk {
    datastore_id = "local"
    size         = 8
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "test3"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_24.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "ubuntu"
  }

  # mount_point {
  #   # volume mount, a new volume will be created by PVE
  #   volume = "local-lvm"
  #   size   = "10G"
  #   path   = "/mnt/volume"
  # }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = "hub.local"
    private_key = file("~/.ssh/hub.local")
  }

  provisioner "file" {
    source      = "test1-init.sh"
    destination = "/root/test1-init.sh"
  }

  provisioner "remote-exec" {
    when = create
    inline = [
      "id=${proxmox_virtual_environment_container.ubuntu_container.id}",
      "pct push $id /root/test1-init.sh /root/init.sh",
      "lxc-attach -n $id -- bash init.sh"
    ]
  }
}

resource "proxmox_virtual_environment_container" "plex" {
  description = "Managed by Terraform"

  node_name = "hub"
  vm_id     = 102

  disk {
    datastore_id = "local"
    size         = 8
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "plex"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_24.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "ubuntu"
  }

  mount_point {
    # volume mount, a new volume will be created by PVE
    # volume = "local-lvm"
    # size   = "10G"
    volume = "/root/data/plex"
    path   = "/var/lib/plexmediaserver"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = "hub.local"
    private_key = file("~/.ssh/hub.local")
  }

  provisioner "file" {
    source      = "containers/plex/init.sh"
    destination = "/root/init/plex/init.sh"
  }

  provisioner "file" {
    source      = "containers/plex/media-nas.mount"
    destination = "/root/init/plex/media-nas.mount"
  }


  provisioner "remote-exec" {
    when = create
    inline = [
      "id=${proxmox_virtual_environment_container.plex.id}",

      "pct push $id /root/init/plex/init.sh /root/init.sh",
      "pct push $id /root/init/plex/media-nas.mount /root/media-nas.mount",

      "lxc-attach -n $id -- bash init.sh"
    ]
  }
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_24" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "hub"
  # http://download.proxmox.com/images/system/
  url = "http://download.proxmox.com/images/system/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
}

resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "vmid" {
  value     = proxmox_virtual_environment_container.ubuntu_container.id
  sensitive = true
}

output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}
