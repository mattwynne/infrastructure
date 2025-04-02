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
