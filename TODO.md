big goal:
  refactor current setup to be ready to absorb more containers

  - Next steps / options:
    - abstract VM_IDs using some kind of random number generator
    - avoid using local storage on the proxmox server for easy re-paving
      - could we terraform/auto-provision the proxmox server itself?
      - could we set up a share to the NAS on the proxmox host and use that?
      - give each vm space on the NAS for data storage volumes
    - make copying files onto new VM more conventional
    - tidy up secrets templating for plex server media mount point
      - https://developer.1password.com/docs/connect/ansible-collection/
      - https://www.redhat.com/en/blog/ansible-playbooks-secrets
    - try using packer to build the container images?
    - investigate how I could use nix to configure the containers?
