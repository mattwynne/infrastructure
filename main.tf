resource "proxmox_virtual_environment_container" "container" {
  for_each = local.containers

  description = "Managed by Terraform"

  node_name = "hub"

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
      keys     = [trimspace(tls_private_key.container_key.public_key_openssh)]
      password = random_password.container_password.result
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_24.id
    type             = "ubuntu"
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
    for_each = each.value.mount
    content {
      volume = mount_point.value.volume
      path   = mount_point.value.path
    }
  }
}
