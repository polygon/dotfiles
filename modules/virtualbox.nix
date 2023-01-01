{ config, lib, pkgs, ... }:

with lib;

# Base config for all Linux systems

let
  cfg = config.modules.apps.virtualbox;
in
{
  options.modules.apps.virtualbox.enable = mkEnableOption "VirtualBox Host";

  config = mkIf cfg.enable {
    virtualisation.virtualbox = {
      host.enable = true;
      host.enableExtensionPack = true;
      host.enableHardening = true;
      host.addNetworkInterface = true;

    };
    
    users.extraGroups.vboxusers.members = [ "jan" ];
  };
}
