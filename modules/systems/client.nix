{ config, lib, pkgs, ... }:

with lib;

# Config that should be the same on all client/workstation machines

let
  cfg = config.modules.systems.client;
in
{
  options.modules.systems.client.enable = mkEnableOption "Client Machine";

  config = mkIf cfg.enable {
    time.timeZone = "Europe/Berlin";
    
    # Deprecated
    networking.useDHCP = false;
    nix = {
      trustedUsers = [ "jan" ];
      extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
      '';
      package = pkgs.nixUnstable;
    }; 

    systemd.network.enable = true;
    systemd.services.systemd-networkd-wait-online.enable = false;
    systemd.services.systemd-networkd.restartIfChanged = false;
    networking.networkmanager.enable = false;    

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        #font = "ter-v32n"
        keyMap = "de";
    };    

    users.users.jan = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" "video" "plugdev" ]; # Enable ‘sudo’ for the user.
      shell = pkgs.zsh;
    };    

    users.groups.plugdev = {};

    environment.systemPackages = with pkgs; [
      cryptsetup
      vim
      git
      killall
      bind.dnsutils
      tcpdump
      nmap
      usbutils
      wget
    ];

    fonts.fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];    

    environment.pathsToLink = [ "/share/zsh" "/share/nix-direnv" ]; 
  
    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  
    programs.ssh = {
      startAgent = true;
      agentTimeout = null;
    }; 
  }; 
}
