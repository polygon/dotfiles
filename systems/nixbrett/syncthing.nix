{ config, pkgs, secrets, ... }:
{
  services.syncthing = {
    enable = true;
    user = "jan";
    dataDir = "/home/jan/syncthing";
    configDir = "/home/jan/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    devices."cloud"= {
      id = (import "${secrets}/syncthing.nix").cloud;
      addresses = [ "tcp4://192.168.1.24" ];
    };
  
    folders."bitwig" = {
      path = "/home/jan/Bitwig Studio";
      devices = [ "cloud" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };
}
