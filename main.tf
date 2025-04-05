locals {
  containers = {
    sandbox = {
      vm_id = 101
      hostname = "sandbox"
    }
    plex = {
      vm_id = 102
      hostname = "plex"
    }
  }
}

resource "proxmox_virtual_environment_container" "container" {
  for_each = local.containers

  description = "Managed by Terraform"

  node_name = "hub"
  vm_id     = each.value.vm_id

  disk {
    datastore_id = "local"
    size         = 8
  }

  features {
    nesting = true
  }

  initialization {
    hostname = each.value.hostname

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

  dynamic "mount_point" {
    for_each = each.key == "plex" ? [1] : []
    content {
      volume = "/root/data/plex"
      path   = "/var/lib/plexmediaserver"
    }
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
    "sandbox" = proxmox_virtual_environment_container.sandbox
    "plex"    = proxmox_virtual_environment_container.plex
  }
}

output "container_vmid_map" {
  value = {
    for name, container in local.container_map :
    name => container.id
  }
}
