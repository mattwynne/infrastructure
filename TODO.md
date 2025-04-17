big goal:
  refactor current setup to be ready to absorb more containers

  - Next steps / options:
    - install https://nginxproxymanager.com/ 
      - **avoid using local storage on the proxmox server for easy re-paving**
        - sql didn't work - SQLITE_BUSY
        - trying postgres. Similarly seems to have permissions issues with the share
        - maybe be something to do with docker, and the user that pg user?
    - make copying files onto new VM more conventional?
    - avoid using local storage on the proxmox server for easy re-paving
      - tidy up secrets templating for plex server media mount point
        - https://developer.1password.com/docs/connect/ansible-collection/
        - https://www.redhat.com/en/blog/ansible-playbooks-secrets
    - try using packer to build the container images?
    - investigate how I could use nix to configure the containers?
    - figure out a good general setup for docker containers
      - e.g. https://www.portainer.io
