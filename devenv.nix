{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [ 
    git 
    aider-chat
    terraform
    adrgen
    ansible
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  scripts.make-plex.exec = ''
    if [ -z "$NAS_PASSWORD" ]; then
      echo "Error: NAS_PASSWORD environment variable is not set."
      exit 1
    fi
    sed "s/PLACEHOLDER_PASSWORD/$NAS_PASSWORD/" containers/plex/media-nas.mount.template > containers/plex/media-nas.mount
  '';

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  scripts.ip.exec = ''
    name=$1
    id=$(vmid $name)
    local_range="192.168.1"
    ssh hub.local "
      ip=""
      while [ -z \"\$ip\" ]; do
        ip=\$(lxc-info -i -n $id | grep 'IP' | grep '$local_range' | awk '{print \$2}')
      done
      echo \$ip
    "
  '';

  scripts.apply.exec = ''
    terraform apply -auto-approve
  '';

  scripts.destroy.exec = ''
    name=$1
    id=$(vmid $name)
    ssh hub.local pct destroy $id --force --purge
  '';

  scripts.reapply.exec = ''
    make-plex
    # TODO: destroy as a loop
    destroy plex
    destroy sandbox
    destroy proxy
    apply
    # TODO: provision as a loop
    provision plex
    provision sandbox
    provision proxy
  '';

  scripts.console.exec = ''
    name=$1
    ip=$(ip $name)

    ssh-keygen -qR $ip > /dev/null 2>&1
    terraform output -raw container_private_key > /tmp/private_key.pem
    chmod 600 /tmp/private_key.pem

    ssh -q \
      -o StrictHostKeyChecking=no \
      -i /tmp/private_key.pem \
      root@$ip

    rm /tmp/private_key.pem
  '';

  scripts.provision.exec = ''
    name=$1
    if [ -z "$name" ]; then
      # TODO: can we parallelize provisioning?
      for name in $(list-containers); do
        provision $name 
      done
    else
      ip=$(ip $name)
      if [ -f containers/$name/init.sh ]; then
        provision-init $name
      else
        provision-ansible $name
      fi
    fi
  '';

  scripts.provision-init.exec = ''
    name=$1
    id=$(vmid $name)

    scp containers/$name/init.sh hub.local:/root/$name-init.sh
    ssh hub.local pct push $id /root/$name-init.sh /root/init.sh
    ssh hub.local lxc-attach -n $id -- bash init.sh
    ssh hub.local lxc-attach -n $id -- rm /root/init.sh
  '';

  scripts.provision-ansible.exec = ''
    name=$1
    ip=$(ip $name)

    # Set up key
    ssh-keygen -qR $ip > /dev/null 2>&1
    terraform output -raw container_private_key > /tmp/private_key.pem
    chmod 600 /tmp/private_key.pem

    # Run playbook
    ansible-playbook -i $ip, containers/$name/playbook.yml -u root --private-key /tmp/private_key.pem

    # Remove key
    rm /tmp/private_key.pem
  '';

  scripts.list-containers.exec = ''
  terraform output -json | jq -r '.containers.value | keys []'
  '';

  scripts.vmid.exec = ''
    name=$1
    terraform output -json | \
      jq -r --arg name "$name" '.ids.value[$name]'
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
