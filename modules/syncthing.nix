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
    includeAddresses = mkOption {
      type = types.bool;
      default = true;
      description = "Include IP addresses of devices";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "jan";
      dataDir = cfg.basePath;
      configDir = "${cfg.basePath}/.config/syncthing";
      guiAddress = cfg.guiAddress;

      settings = {
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
          addresses = lib.optionals cfg.includeAddresses [ "tcp4://192.168.1.24" ];
        };
        devices."nixbrett" = {
          id = sync_ids.nixbrett;
          addresses = lib.optionals cfg.includeAddresses [ "tcp://nixbrett.matelab.de" ];
        };
        devices."cube" = {
          id = sync_ids.cube;
          addresses = lib.optionals cfg.includeAddresses [ "tcp://cube.matelab.de" ];
        };
  
        devices."fon" = {
          id = sync_ids.fon;
          addresses = lib.optionals cfg.includeAddresses [ "tcp://192.168.1.183" ];
        };

        devices."sync" = {
          id = sync_ids.sync;
          addresses = lib.optionals cfg.includeAddresses [ "tcp://sync.nubego.de" ];
        };

        folders."bitwig" = {
          path = "${cfg.basePath}/Bitwig Studio";
          devices = [ "cloud" "nixbrett" "cube" ];
        };

        folders."blender" = {
          path = "${cfg.basePath}/blender";
          devices = [ "cloud" "nixbrett" "cube" ];
        };
  
        folders."audiolib" = {
          path = "${cfg.basePath}/audiolib";
          devices = [ "cloud" "nixbrett" "cube" ];
        };
  
        folders."obsidian" = {
          path = "${cfg.basePath}/obsidian";
          devices = [ "cloud" "nixbrett" "cube" "fon" "sync" ];
        };
  
        folders."Documents" = {
          path = "${cfg.basePath}/Documents";
          devices = [ "cloud" "nixbrett" "cube" "sync" ];
        };
  
        folders."Pictures" = {
          path = "${cfg.basePath}/Pictures";
          devices = [ "cloud" "nixbrett" "cube" "sync" ];
        };
  
        folders."wine-vst64" = {
          path = "${cfg.basePath}/.local/share/wineprefixes/wine-vst64";
          devices = [ "cloud" "nixbrett" "cube" ];
        };

        folders."Photos" = {
          path = "${cfg.basePath}/Photos";
          devices = [ "cloud" "nixbrett" "cube" "sync" "fon" ];
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 ];
    };
  };
}
