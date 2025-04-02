resource "proxmox_virtual_environment_download_file" "latest_ubuntu_24" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "hub"
  # http://download.proxmox.com/images/system/
  url = "http://download.proxmox.com/images/system/ubuntu-24.10-standard_24.10-1_amd64.tar.zst"
}
