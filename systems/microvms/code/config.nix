# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, secrets, ... }:
{
  # == Module Configuration ==

  modules.systems.microvm.enable = true;

  networking = {
    domain = "matelab.de";
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  systemd.services.systemd-networkd-wait-online.enable = pkgs.lib.mkForce false;
  systemd.network = {
    enable = true;
    # Configure bridges for networks that we want the host to have access to
    networks."lan" = {
      matchConfig.MACAddress = "ba:da:55:04:00:00";
      addresses = [ { 
        Address = "192.168.1.25/24";
      } ];
      networkConfig = {
        Gateway = "192.168.1.1";
        DNS = "192.168.1.1";
      };
    };
    networks."server" = {
      matchConfig.MACAddress = "ba:da:55:04:00:01";
      addresses = [ { 
        Address = "192.168.3.25/24";
      } ];
    };
  };

  services.resolved.enable = true;
  
  environment.systemPackages = let
    cfg = config.services.forgejo;
    forgejo-admin =
      (pkgs.writeShellScriptBin "forgejo-admin" ''
        exec sudo -u ${cfg.user} env \
        FORGEJO_WORK_DIR=${cfg.stateDir} \
        FORGEJO_CUSTOM=${cfg.customDir} \
        ${pkgs.lib.getExe cfg.package} "$@"
      ''
      );
  in with pkgs; [
    ripgrep forgejo-admin
  ];

  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "admin" "git" ];
    };
  };

  users.users.git = {
    uid = 990;
    isSystemUser = true;
    group = "git";
    home = config.services.forgejo.stateDir;
    useDefaultShell = true;
  };
  users.groups.git.gid = 990;

  services.forgejo = {
    user = "git";
    group = "git";

    enable = true;
    package = pkgs.forgejo;

    database = {
      type = "sqlite3";
    };

    lfs.enable = true;

    dump = {
      enable = true;
      type = "tar.zst";
      interval = "04:31";
    };

    settings = {
      DEFAULT.APP_NAME = "code";

      server = {
        DOMAIN = "code.matelab.de";
        ROOT_URL = "https://code.matelab.de/";
        HTTP_ADDR = "192.168.3.25";
        HTTP_PORT = 3000;

        START_SSH_SERVER = false;
        SSH_DOMAIN = "ssh.code.matelab.de";
        SSH_PORT = 22;
        SSH_USER = "git";

        LANDING_PAGE = "explore";
        DISABLE_ROUTER_LOG = true;
      };

      database.SQLITE_JOURNAL_MODE = "WAL";

      service = {
        DISABLE_REGISTRATION = true;
        REQUIRE_SIGNIN_VIEW = true;
      };

      session.COOKIE_SECURE = true;

      security.REVERSE_PROXY_TRUSTED_PROXIES = "192.168.1.20";

      repository = {
        DEFAULT_PRIVATE = "private";
        DEFAULT_BRANCH = "main";
      };

      indexer.REPO_INDEXER_ENABLED = true;

      actions.ENABLED = false;

      log.LEVEL = "Warn";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];

  #sops.defaultSopsFile = "${secrets}/hosts/playground/secret.yaml";
  #sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  #sops.gnupg.sshKeyPaths = [ ];
  #sops.secrets.mqttbridge = { };
  #sops.secrets.user = { };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}

