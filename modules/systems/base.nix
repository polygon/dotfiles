{ config, lib, pkgs, ... }:

with lib;

# Base config for all Linux systems

let
  cfg = config.modules.systems.base;
in
{
  options.modules.systems.base.enable = mkEnableOption "Linux Base System";

  config = mkIf cfg.enable {
    time.timeZone = "Europe/Berlin";
    
    # Deprecated
    networking.useDHCP = false;
    nix = {
      extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
      '';
      package = pkgs.nixUnstable;
    }; 

    systemd.network.enable = true;

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
        #font = "ter-v32n"
        keyMap = "de";
    };    

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
      tmux
      direnv
      sops
      rage
      ssh-to-age
      pwgen
    ];

    environment.pathsToLink = [ "/share/zsh" "/share/nix-direnv" ]; 
  
    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
  }; 
}
