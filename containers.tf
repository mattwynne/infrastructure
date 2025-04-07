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
}
