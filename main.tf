resource "proxmox_virtual_environment_container" "sandbox" {
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
    hostname = "sandbox"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.container_key.public_key_openssh)
      ]
      password = random_password.container_password.result
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
        trimspace(tls_private_key.container_key.public_key_openssh)
      ]
      password = random_password.container_password.result
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

  # TODO: these data folders should be on the nas too so we can re-pave the hub
  mount_point {
    volume = "/root/data/plex"
    path   = "/var/lib/plexmediaserver"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "random_password" "container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "container_private_key" {
  value     = tls_private_key.container_key.private_key_pem
  sensitive = true
}

output "container_public_key" {
  value = tls_private_key.container_key.public_key_openssh
}

output "container_plex_vmid" {
  value = proxmox_virtual_environment_container.plex.id
}

output "container_sandbox_vmid" {
  value = proxmox_virtual_environment_container.sandbox.id
}


locals {
  container_map = {
    for name, container in proxmox_virtual_environment_container :
    name => container
  }
}

output "container_vmid_map" {
  value = {
    for name, container in local.container_map :
    name => container.id
  }
}
