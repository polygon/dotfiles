{ config, lib, pkgs, secrets, ... }:

with lib;

# Base config for all Linux systems

let
  cfg = config.modules.apps.syncthing;
  sync_ids = import "${secrets}/syncthing.nix";
in
{
  options.modules.apps.syncthing = {
    enable = mkEnableOption "Syncthing";
    basePath = mkOption {
      type = types.path;
      default = "/home/jan";
      description = "Syncthing basepath";
    };
    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "Syncthing listen address";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "jan";
      dataDir = cfg.basePath;
      configDir = "${cfg.basePath}/.config/syncthing";
      guiAddress = cfg.guiAddress;

      extraOptions = {
        options = {
          globalAnnounceEnabled = false;
          localAnnounceEnabled = false;
          relaysEnabled = false;
          natEnabled = false;
          crashReportingEnabled = false;
          announceLANAddresses = false;
        };
      };

      devices."cloud" = {
        id = sync_ids.cloud;
        addresses = [ "tcp4://192.168.1.24" ];
      };
      devices."nixbrett" = {
        id = sync_ids.nixbrett;
        addresses = [ "tcp://nixbrett.matelab.de" ];
      };
      devices."cube" = {
        id = sync_ids.cube;
        addresses = [ "tcp://cube.matelab.de" ];
      };

      devices."fon" = {
        id = sync_ids.fon;
        addresses = [ "tcp://192.168.1.183" ];
      };

      folders."bitwig" = {
        path = "${cfg.basePath}/Bitwig Studio";
        devices = [ "cloud" "nixbrett" "cube" ];
      };

      folders."audiolib" = {
        path = "${cfg.basePath}/audiolib";
        devices = [ "cloud" "nixbrett" "cube" ];
      };

      folders."obsidian" = {
        path = "${cfg.basePath}/obsidian";
        devices = [ "cloud" "nixbrett" "cube" "fon" ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 ];
    };
  };
}
