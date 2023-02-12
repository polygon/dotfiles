{ config, pkgs, secrets, ... }:
{
  users.users.jan = {
    isNormalUser = true;
    uid = 1000;
  };

  modules.apps.syncthing = {
    enable = true;
    basePath = "/storage/hdd";
    guiAddress = "192.168.3.24:8384";
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
