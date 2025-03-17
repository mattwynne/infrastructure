variable "pm_api_url" {
  description = "Proxmox API URL"
}

variable "pm_user" {
  description = "Proxmox user"
}

variable "pm_password" {
  description = "Proxmox password"
  sensitive   = true
}

variable "pm_target_node" {
  description = "Proxmox target node"
}

variable "pm_clone_template" {
  description = "Proxmox VM clone template"
}

variable "lxc_template" {
  description = "Proxmox LXC template"
}
