{ config, lib, pkgs, ... }:

with lib;

# Config that should be the same on all client/workstation machines

let
  cfg = config.modules.systems.client;
in
{
  options.modules.systems.client.enable = mkEnableOption "Client Machine";

  config = mkIf cfg.enable {
    modules.systems.base.enable = true;
    
    nix.trustedUsers = [ "jan" ];

    systemd.services.systemd-networkd-wait-online.enable = false;
    systemd.services.systemd-networkd.restartIfChanged = false;
    networking.networkmanager.enable = false;    

    users.users.jan = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" "video" "plugdev" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
    };    

    users.groups.plugdev = {};

    environment.systemPackages = with pkgs; [
      gnupg
    ];

    fonts.fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];    

    programs.ssh = {
      startAgent = true;
      agentTimeout = null;
    }; 
  }; 
}
