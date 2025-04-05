resource "random_password" "container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
