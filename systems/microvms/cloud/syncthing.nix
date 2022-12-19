{ config, pkgs, ... }:
{
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
  };

  services.syncthing = {
    enable = true;
    user = "jan";
    dataDir = "/storage/hdd";
    configDir = "/storage/hdd/.config/syncthing";
    guiAddress = "192.168.3.24:8384";
  };

  networking.firewall = {
    allowedTCPPorts = [ 8384 20000 ];
    allowedUDPPorts = [ 20000 ];
  };
}
