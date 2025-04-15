big goal:
  refactor current setup to be ready to absorb more containers

  - Next steps / options:
    - install https://nginxproxymanager.com/ 
      - figure out a good general setup for docker containers
      - trying to get to use mdns names on the docker container
        - trying to rebuild the container with avahi-utils, see https://medium.com/@andrejtaneski/using-mdns-from-a-docker-container-b516a408a66b
          - need to be able to set this to enable apparmor to work:
            https://www.reddit.com/r/selfhosted/comments/1436ekf/looking_for_lxcfriendly_docker_install/
            - set this by hand for now
            - hack: https://github.com/bpg/terraform-provider-proxmox/issues/256
	- e.g. https://www.portainer.io
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
