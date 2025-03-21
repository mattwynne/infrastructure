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
    id=$(basename $1)
    ssh hub.local "
      ip=""
      while [ -z \"\$ip\" ]; do
        ip=\$(lxc-info -i -n $id | grep 'IP' | awk '{print \$2}')
      done
      echo \$ip
    "
  '';

  scripts.apply.exec = ''
    terraform apply -auto-approve
  '';

  scripts.destroy.exec = ''
    terraform destroy -auto-approve
  '';

  scripts.reapply.exec = ''
    make-plex
    destroy
    apply
  '';

  scripts.console.exec = ''
    id=$(basename $1)
    ip=$(ip $id)
    ssh -i ~/.ssh/hub.local root@$ip
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
