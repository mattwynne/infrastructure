big goal:
  refactor current setup to be ready to absorb more containers

  - Next steps / options:
    - experiment with terraform modules or reading yaml to simplify the machine configuration
    - tidy up secrets templating for mount point
      - https://developer.1password.com/docs/connect/ansible-collection/
      - https://www.redhat.com/en/blog/ansible-playbooks-secrets
    - try using packer to build the container image
    - investigate how I could use nix to configure the container
