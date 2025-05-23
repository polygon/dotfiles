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
    
    nix.settings.trusted-users = [ "jan" ];

    systemd.services.systemd-networkd-wait-online.enable = mkForce false;
    systemd.services.systemd-networkd.restartIfChanged = false;
    networking.networkmanager.enable = false;    

    users.users.jan = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" "video" "plugdev" "dialout" "input" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
    };    

    environment.shells = [ pkgs.zsh ];

    users.groups.plugdev = {};

    environment.systemPackages = with pkgs; [
      gnupg
      nixd
      nixfmt-classic
      mc
      obsidian
      chromium
      cntr
      nix-init
      appimage-run
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      meslo-lgs-nf
      xorg.fontcursormisc
    ];    

    programs.ssh = {
      startAgent = true;
      agentTimeout = null;
    }; 

    programs.i3lock = {
      enable = true;
      package = pkgs.i3lock-color;
    };

    programs.nix-ld.enable = true;
    programs.fuse.userAllowOther = true;

    services.openssh.settings.X11Forwarding = true;
  }; 
}
