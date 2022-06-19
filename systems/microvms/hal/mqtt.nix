{ config, pkgs, ... }:               
{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "0.0.0.0";
        users."admin" = {
          passwordFile = config.sops.secrets.mosquitto-users-admin.path;
          acl = [
            "readwrite #"
          ];
        };
        users."plugs" = {
          passwordFile = config.sops.secrets.mosquitto-users-plugs.path;
          acl = [
            "readwrite plugs/#"
            "readwrite tasmota/#"
          ];
        };
      }
    ];

    bridges.pi = {
      addresses = [ { address = "192.168.3.10"; } ];
      topics = [ "plugs/# in" "tasmota/# in" ];
      settings = {
        remote_username = "!!BRIDGE_PI_USERNAME!!";
        remote_password = "!!BRIDGE_PI_PASSWORD!!";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];
}
