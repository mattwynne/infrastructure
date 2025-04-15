locals {
  container_names = toset(
    flatten(
      [
        for k, _ in toset(fileset("${path.module}/containers", "**"))
        : dirname(k)
      ]
    )
  )

  containers = {
    for name in local.container_names :
    name => merge(
      yamldecode(file("${path.module}/containers/${name}/container.yml")),
      { hostname = name }
    )
  }

  mac_addresses = {
    for name in local.container_names :
    name => format(
      "02:00:%02x:%02x:%02x:%02x",
      parseint(substr(md5(name), 0, 2), 16),
      parseint(substr(md5(name), 2, 2), 16),
      parseint(substr(md5(name), 4, 2), 16),
      parseint(substr(md5(name), 6, 2), 16)
    )
  }
}
