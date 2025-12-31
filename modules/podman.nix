{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.apps.podman;
in {
  options.modules.apps.podman.enable =
    mkEnableOption "Container Virtualization";

  config = mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled =
          true; # Required for containers under podman-compose to be able to talk to each other.
      };
    };

    environment.systemPackages = [ pkgs.distrobox pkgs.podman-compose ];

    users.users.jan = { # replace `<USERNAME>` with the actual username
      extraGroups = [ "podman" ];
    };
  };

}
