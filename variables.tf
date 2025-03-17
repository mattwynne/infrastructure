
variable "api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "host"
}

variable "user" {
  description = "Proxmox user"
  type        = string
}

variable "password" {
  description = "Proxmox password"
  type        = string
}
